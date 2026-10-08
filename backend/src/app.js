require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db');
const { sendOtp, checkOtp } = require('./emailAuth');
const googleAuth = require('./googleAuth');

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
 throw new Error('JWT_SECRET must be set to a random secret of at least 32 characters');
}

const DELIVERY_FEE = 1500;

const STATUS_TO_DB = { Processing: 'PENDING', Confirmed: 'PROCESSING', Shipped: 'SHIPPED', Delivered: 'DELIVERED', Cancelled: 'CANCELLED' };
const STATUS_LABEL = { PENDING: 'Processing', PAID: 'Confirmed', PROCESSING: 'Confirmed', SHIPPED: 'Shipped', OUT_FOR_DELIVERY: 'Shipped', DELIVERED: 'Delivered', CANCELLED: 'Cancelled' };
const PAYMENT_LABEL = { CARD: 'Card', BANK_TRANSFER: 'Bank Transfer', PAY_ON_DELIVERY: 'Pay on Delivery' };
const paymentToDb = label => /card/i.test(label) ? 'CARD' : /bank/i.test(label) ? 'BANK_TRANSFER' : 'PAY_ON_DELIVERY';

const roleOut = role => role === 'ADMIN' ? 'admin' : 'customer';
const flag = value => (value === true || value === 1 || value === 'true') ? 1 : 0;
const wrap = fn => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
const fail = (res, status, message) => res.status(status).json({ error: message });
const cleanEmail = value => String(value || '').trim().toLowerCase();

const BOOK_COLS = `b.id, b.title, a.name AS author, b.description, b.imageUrl, b.price, b.stockQuantity,
 b.ratingAvg, b.ratingCount, b.isBestseller, b.isNewArrival, b.isFeatured,
 (SELECT g.name FROM BookGenres bg JOIN Genres g ON g.id = bg.genreId WHERE bg.bookId = b.id ORDER BY g.id LIMIT 1) AS genre`;
const BOOK_JOINS = 'JOIN Authors a ON a.id = b.authorId';

function mapBook(row) {
 return { id: String(row.id), title: row.title, author: row.author, genre: row.genre || '', description: row.description || '',
  coverUrl: row.imageUrl || '', price: Number(row.price), stock: row.stockQuantity, rating: Number(row.ratingAvg),
  reviewCount: row.ratingCount, isBestseller: !!row.isBestseller, isNewArrival: !!row.isNewArrival, isFeatured: !!row.isFeatured };
}
async function getBook(id) {
 const [rows] = await db.query(`SELECT ${BOOK_COLS} FROM Books b ${BOOK_JOINS} WHERE b.id = ?`, [id]);
 return rows[0] ? mapBook(rows[0]) : null;
}
async function mapOrder(row) {
 const [itemRows] = await db.query(
  `SELECT oi.bookId, oi.title, oi.quantity, oi.price, a.name AS author, b.imageUrl
   FROM OrderItems oi LEFT JOIN Books b ON b.id = oi.bookId LEFT JOIN Authors a ON a.id = b.authorId
   WHERE oi.orderId = ? ORDER BY oi.id`, [row.id]);
 const items = itemRows.map(item => ({ bookId: item.bookId == null ? '' : String(item.bookId), title: item.title, author: item.author || '',
  coverUrl: item.imageUrl || '', unitPrice: Number(item.price), quantity: item.quantity, totalPrice: Number(item.price) * item.quantity }));
 const [payment] = await db.query('SELECT method FROM Payments WHERE orderId = ? ORDER BY id DESC LIMIT 1', [row.id]);
 const subtotal = items.reduce((sum, item) => sum + item.totalPrice, 0), total = Number(row.totalAmount);
 return { id: String(row.id), items, subtotal, deliveryFee: Math.max(0, total - subtotal), total,
  customerName: row.shippingName, phone: row.shippingPhone || '', address: row.shippingStreet, city: row.shippingCity,
  paymentMethod: payment[0] ? PAYMENT_LABEL[payment[0].method] : '', createdAt: row.createdAt, status: STATUS_LABEL[row.status] || row.status };
}
function publicUser(row) {
 return { id: String(row.id), name: row.name, email: row.email, phone: row.phone || '', role: roleOut(row.role), createdAt: row.createdAt };
}
function tokenFor(user) { return jwt.sign({ sub: String(user.id), role: roleOut(user.role) }, process.env.JWT_SECRET, { expiresIn: '7d' }); }

async function tx(work) {
 const conn = await db.getConnection();
 try { await conn.beginTransaction(); const result = await work(conn); await conn.commit(); return result; }
 catch (error) { await conn.rollback(); throw error; }
 finally { conn.release(); }
}

async function idByName(conn, table, name) {
 const [rows] = await conn.query(`SELECT id FROM ${table} WHERE name = ? LIMIT 1`, [name]);
 if (rows.length) return rows[0].id;
 const [result] = await conn.query(`INSERT INTO ${table} (name) VALUES (?)`, [name]);
 return result.insertId;
}
function validateBook(body, partial = false) {
 for (const key of ['title', 'author', 'genre', 'description', 'coverUrl', 'price', 'stock']) if (!partial || body[key] !== undefined) {
  const value = body[key];
  if (['title', 'author', 'genre'].includes(key) && (typeof value !== 'string' || !value.trim())) return `${key} is required`;
  if (key === 'price' && (!Number.isFinite(Number(value)) || Number(value) < 0)) return 'price must be zero or greater';
  if (key === 'stock' && (!Number.isInteger(Number(value)) || Number(value) < 0)) return 'stock must be a non-negative integer';
  if (['description', 'coverUrl'].includes(key) && value != null && typeof value !== 'string') return `${key} must be a string`;
 }
 return null;
}

const createApp = async () => {
 await db.checkSchema();

 const app = express();
 app.disable('x-powered-by');
 const allowedOrigins = process.env.CLIENT_ORIGIN?.split(',').map(value => value.trim()).filter(Boolean);
 app.use(cors({ origin: allowedOrigins ? (origin, callback) => {
  if (!origin || allowedOrigins.some(pattern => pattern === '*' || (pattern.includes('*') && new RegExp(`^${pattern.split('*').map(part => part.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('.*')}$`).test(origin)) || pattern === origin)) return callback(null, true);
  callback(new Error('Origin is not allowed by CORS'));
 } : true }));
 app.use(express.json({ limit: '1mb' }));
 app.use('/api/auth', rateLimit({ windowMs: 15 * 60 * 1000, limit: Number(process.env.AUTH_RATE_LIMIT || 30), standardHeaders: true, legacyHeaders: false }));

 function auth(requiredRole) {
  return async (req, res, next) => {
   try {
    const token = (req.headers.authorization || '').replace(/^Bearer\s+/i, '');
    if (!token) return fail(res, 401, 'Authentication required');
    let claims;
    try { claims = jwt.verify(token, process.env.JWT_SECRET); } catch { return fail(res, 401, 'Invalid or expired token'); }
    const [rows] = await db.query('SELECT id,name,email,phone,role,disabled,createdAt FROM Users WHERE id = ?', [claims.sub]);
    if (!rows[0] || rows[0].disabled) return fail(res, 401, 'Account unavailable');
    const role = roleOut(rows[0].role);
    if (requiredRole && role !== requiredRole) return fail(res, 403, 'Admin access required');
    req.user = { ...rows[0], role };
    next();
   } catch (error) { next(error); }
  };
 }
 const customer = auth();
 const admin = auth('admin');

 app.get('/api/health', (_req, res) => res.json({ status: 'ok', service: 'shelfspace-api' }));

 app.post('/api/auth/register', wrap(async (req, res) => {
  const { name, email, password, phone = '' } = req.body || {};
  if (typeof name !== 'string' || name.trim().length < 2 || typeof email !== 'string' || !/^\S+@\S+\.\S+$/.test(email) || typeof password !== 'string' || password.length < 8) return fail(res, 400, 'Provide a name, valid email, and password of at least 8 characters');
  const mail = cleanEmail(email), passwordHash = await bcrypt.hash(password, 12);
  const [found] = await db.query('SELECT * FROM Users WHERE email = ?', [mail]);
  const existing = found[0];
  if (existing && existing.isVerified) return fail(res, 409, 'Email is already registered');
  let id;
  if (existing) {
   id = existing.id;
   await db.query('UPDATE Users SET name=?, passwordHash=?, phone=? WHERE id=?', [name.trim(), passwordHash, String(phone).trim(), id]);
  } else {
   const [result] = await db.query('INSERT INTO Users (name,email,passwordHash,phone,isVerified) VALUES (?,?,?,?,FALSE)', [name.trim(), mail, passwordHash, String(phone).trim()]);
   id = result.insertId;
  }
  const [rows] = await db.query('SELECT * FROM Users WHERE id = ?', [id]);
  let emailSent = true;
  try { await sendOtp(db, rows[0], 'EMAIL_VERIFY', { force: !existing }); } catch (mailError) { console.error('Could not send verification email:', mailError.message); emailSent = false; }
  res.status(201).json({ message: emailSent ? 'Account created. Enter the code we emailed you to verify your account.' : 'Account created, but the verification email could not be sent. Tap Resend to try again.', email: mail, emailSent, requiresVerification: true });
 }));
 app.post('/api/auth/verify-email', wrap(async (req, res) => {
  const mail = cleanEmail(req.body?.email), otp = String(req.body?.otp || '').trim();
  if (!/^\d{6}$/.test(otp)) return fail(res, 400, 'Enter the 6-digit code');
  const [rows] = await db.query('SELECT * FROM Users WHERE email = ?', [mail]);
  const user = rows[0];
  if (!user || user.isVerified) return fail(res, 400, 'Code is invalid or expired. Please request a new one.');
  const result = await checkOtp(db, user.id, 'EMAIL_VERIFY', otp);
  if (!result.ok) return fail(res, result.status, result.error);
  await db.query('UPDATE Users SET isVerified = TRUE WHERE id = ?', [user.id]);
  res.json({ message: 'Email verified. You can now log in.' });
 }));
 app.post('/api/auth/resend-otp', wrap(async (req, res) => {
  const [rows] = await db.query('SELECT * FROM Users WHERE email = ?', [cleanEmail(req.body?.email)]);
  if (rows[0] && !rows[0].isVerified) {
   try { await sendOtp(db, rows[0], 'EMAIL_VERIFY'); } catch (mailError) { console.error('Could not send verification email:', mailError.message); return fail(res, 502, 'We could not send the email. Please try again shortly.'); }
  }
  res.json({ message: 'If this account still needs verification, a new code has been sent.' });
 }));
 app.post('/api/auth/login', wrap(async (req, res) => {
  const mail = cleanEmail(req.body?.email), password = String(req.body?.password || '');
  const [rows] = await db.query('SELECT * FROM Users WHERE email = ?', [mail]);
  const user = rows[0];
  if (!user || !user.passwordHash || !await bcrypt.compare(password, user.passwordHash)) return fail(res, 401, 'Email or password is incorrect');
  if (user.disabled) return fail(res, 403, 'Account is disabled');
  if (!user.isVerified) {
   try { await sendOtp(db, user, 'EMAIL_VERIFY'); } catch (mailError) { console.error('Could not send verification email:', mailError.message); }
   return res.status(403).json({ error: 'Please verify your email before logging in', code: 'EMAIL_NOT_VERIFIED', email: user.email });
  }
  res.json({ user: publicUser(user), token: tokenFor(user) });
 }));

 app.post('/api/auth/google', wrap(async (req, res) => {
  if (!process.env.GOOGLE_CLIENT_ID) return fail(res, 503, 'Google sign-in is not set up on the server yet');
  const idToken = req.body?.idToken;
  if (typeof idToken !== 'string' || !idToken) return fail(res, 400, 'idToken is required');
  let profile;
  try { profile = await googleAuth.verifyGoogleIdToken(idToken); } catch { return fail(res, 401, 'Google sign-in could not be verified'); }
  profile.email = String(profile.email || '').toLowerCase();
  if (!profile.email || !profile.emailVerified) return fail(res, 401, 'Your Google email is not verified');

  let [rows] = await db.query("SELECT * FROM Users WHERE authProvider = 'GOOGLE' AND providerId = ?", [profile.sub]);
  let user = rows[0];
  if (!user) {
   [rows] = await db.query('SELECT * FROM Users WHERE email = ?', [profile.email]);
   user = rows[0];
   if (user && user.authProvider === 'GOOGLE') return fail(res, 409, 'This email is linked to a different Google account');
   if (user && !user.isVerified) {
    await db.query("UPDATE Users SET isVerified = TRUE, passwordHash = NULL, authProvider = 'GOOGLE', providerId = ? WHERE id = ?", [profile.sub, user.id]);
   } else if (!user) {
    const name = (profile.name || profile.email.split('@')[0]).slice(0, 100);
    const [result] = await db.query("INSERT INTO Users (name,email,passwordHash,isVerified,authProvider,providerId) VALUES (?,?,NULL,TRUE,'GOOGLE',?)", [name, profile.email, profile.sub]);
    user = { id: result.insertId };
   }
   [rows] = await db.query('SELECT * FROM Users WHERE id = ?', [user.id]);
   user = rows[0];
  }
  if (user.disabled) return fail(res, 403, 'Account is disabled');
  res.json({ user: publicUser(user), token: tokenFor(user) });
 }));
 app.get('/api/auth/me', customer, (req, res) => res.json({ user: publicUser(req.user) }));
 app.patch('/api/auth/me', customer, wrap(async (req, res) => {
  const { name, phone } = req.body || {};
  if (name !== undefined && (typeof name !== 'string' || name.trim().length < 2)) return fail(res, 400, 'Name must contain at least 2 characters');
  if (phone !== undefined && typeof phone !== 'string') return fail(res, 400, 'Phone must be a string');
  await db.query('UPDATE Users SET name = COALESCE(?, name), phone = COALESCE(?, phone) WHERE id = ?', [name?.trim() ?? null, phone?.trim() ?? null, req.user.id]);
  const [rows] = await db.query('SELECT id,name,email,phone,role,createdAt FROM Users WHERE id = ?', [req.user.id]);
  res.json({ user: publicUser(rows[0]) });
 }));
 app.post('/api/auth/change-password', customer, wrap(async (req, res) => {
  const { currentPassword, newPassword } = req.body || {};
  const [rows] = await db.query('SELECT passwordHash FROM Users WHERE id = ?', [req.user.id]);
  if (!rows[0].passwordHash || !await bcrypt.compare(String(currentPassword || ''), rows[0].passwordHash)) return fail(res, 400, 'Current password is incorrect');
  if (typeof newPassword !== 'string' || newPassword.length < 8) return fail(res, 400, 'New password must be at least 8 characters');
  await db.query('UPDATE Users SET passwordHash = ? WHERE id = ?', [await bcrypt.hash(newPassword, 12), req.user.id]);
  res.json({ message: 'Password updated' });
 }));

 app.post('/api/auth/forgot-password', wrap(async (req, res) => {
  const [rows] = await db.query('SELECT * FROM Users WHERE email = ?', [cleanEmail(req.body?.email)]);
  if (rows[0] && !rows[0].disabled) {
   try { await sendOtp(db, rows[0], 'PASSWORD_RESET'); } catch (mailError) { console.error('Could not send reset email:', mailError.message); }
  }
  res.json({ message: 'If the account exists, a reset code has been sent to its email.' });
 }));
 app.post('/api/auth/reset-password', wrap(async (req, res) => {
  const mail = cleanEmail(req.body?.email), otp = String(req.body?.otp || '').trim(), newPassword = req.body?.newPassword;
  if (typeof newPassword !== 'string' || newPassword.length < 8) return fail(res, 400, 'Password must be at least 8 characters');
  if (!/^\d{6}$/.test(otp)) return fail(res, 400, 'Enter the 6-digit code');
  const [rows] = await db.query('SELECT id FROM Users WHERE email = ?', [mail]);
  if (!rows[0]) return fail(res, 400, 'Code is invalid or expired. Please request a new one.');
  const result = await checkOtp(db, rows[0].id, 'PASSWORD_RESET', otp);
  if (!result.ok) return fail(res, result.status, result.error);
  await db.query('UPDATE Users SET passwordHash = ?, isVerified = TRUE WHERE id = ?', [await bcrypt.hash(newPassword, 12), rows[0].id]);
  res.json({ message: 'Password reset successfully. You can now log in.' });
 }));

 app.get('/api/books', wrap(async (req, res) => {
  const { q, genre, sort = 'newest', page = '1', limit = '24' } = req.query;
  const where = [], values = [];
  if (q) {
   where.push('(b.title LIKE ? OR a.name LIKE ? OR EXISTS (SELECT 1 FROM BookGenres bg JOIN Genres g ON g.id = bg.genreId WHERE bg.bookId = b.id AND g.name LIKE ?))');
   values.push(`%${q}%`, `%${q}%`, `%${q}%`);
  }
  if (genre) { where.push('EXISTS (SELECT 1 FROM BookGenres bg JOIN Genres g ON g.id = bg.genreId WHERE bg.bookId = b.id AND g.name = ?)'); values.push(genre); }
  for (const [param, column] of [['featured', 'isFeatured'], ['bestseller', 'isBestseller'], ['newArrival', 'isNewArrival']]) {
   if (req.query[param] !== undefined) { where.push(`b.${column} = ?`); values.push(flag(req.query[param])); }
  }
  const order = { newest: 'b.createdAt DESC, b.id DESC', price_asc: 'b.price ASC', price_desc: 'b.price DESC', rating: 'b.ratingAvg DESC',
   popularity: 'b.soldCount DESC', title: 'b.title ASC' }[sort] || 'b.createdAt DESC, b.id DESC';
  const p = Math.max(1, parseInt(page, 10) || 1), n = Math.min(100, Math.max(1, parseInt(limit, 10) || 24)), filter = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const [count] = await db.query(`SELECT COUNT(*) AS n FROM Books b ${BOOK_JOINS} ${filter}`, values);
  const [rows] = await db.query(`SELECT ${BOOK_COLS} FROM Books b ${BOOK_JOINS} ${filter} ORDER BY ${order} LIMIT ? OFFSET ?`, [...values, n, (p - 1) * n]);
  res.json({ items: rows.map(mapBook), page: p, limit: n, total: count[0].n, pages: Math.ceil(count[0].n / n) });
 }));
 app.get('/api/books/:id', wrap(async (req, res) => {
  const book = await getBook(req.params.id);
  return book ? res.json({ book }) : fail(res, 404, 'Book not found');
 }));
 app.get('/api/books/:id/reviews', wrap(async (req, res) => {
  const [rows] = await db.query(
   'SELECT r.id, r.rating, r.comment, r.createdAt, u.name AS customerName FROM Reviews r JOIN Users u ON u.id = r.userId WHERE r.bookId = ? ORDER BY r.createdAt DESC, r.id DESC', [req.params.id]);
  res.json({ items: rows.map(r => ({ id: String(r.id), rating: r.rating, comment: r.comment || '', created_at: r.createdAt, createdAt: r.createdAt, customerName: r.customerName })) });
 }));
 app.post('/api/books/:id/reviews', customer, wrap(async (req, res) => {
  const rating = Number(req.body?.rating), comment = String(req.body?.comment || '').trim();
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) return fail(res, 400, 'Rating must be an integer from 1 to 5');
  const [book] = await db.query('SELECT id FROM Books WHERE id = ?', [req.params.id]);
  if (!book[0]) return fail(res, 404, 'Book not found');
  try {
   const [result] = await db.query('INSERT INTO Reviews (userId, bookId, rating, comment) VALUES (?,?,?,?)', [req.user.id, book[0].id, rating, comment]);
   res.status(201).json({ id: String(result.insertId), rating, comment });
  } catch (error) { if (error.code === 'ER_DUP_ENTRY') return fail(res, 409, 'You have already reviewed this book'); throw error; }
 }));

 app.get('/api/cart', customer, wrap(async (req, res) => {
  const [rows] = await db.query(`SELECT c.quantity, ${BOOK_COLS} FROM CartItems c JOIN Books b ON b.id = c.bookId ${BOOK_JOINS} WHERE c.userId = ? ORDER BY b.title`, [req.user.id]);
  const items = rows.map(row => ({ book: mapBook(row), quantity: row.quantity }));
  res.json({ items, subtotal: items.reduce((sum, item) => sum + item.book.price * item.quantity, 0) });
 }));
 app.post('/api/cart/items', customer, wrap(async (req, res) => {
  const quantity = Number(req.body?.quantity ?? 1), bookId = parseInt(req.body?.bookId, 10);
  if (!Number.isInteger(quantity) || quantity < 1) return fail(res, 400, 'Quantity must be a positive integer');
  const [books] = await db.query('SELECT id, stockQuantity FROM Books WHERE id = ?', [bookId]);
  if (!books[0]) return fail(res, 404, 'Book not found');
  const [old] = await db.query('SELECT quantity FROM CartItems WHERE userId = ? AND bookId = ?', [req.user.id, bookId]);
  const total = (old[0]?.quantity || 0) + quantity;
  if (total > books[0].stockQuantity) return fail(res, 409, 'Requested quantity exceeds available stock');
  await db.query('INSERT INTO CartItems (userId, bookId, quantity) VALUES (?,?,?) ON DUPLICATE KEY UPDATE quantity = ?', [req.user.id, bookId, total, total]);
  res.status(201).json({ message: 'Item added to cart' });
 }));
 app.patch('/api/cart/items/:bookId', customer, wrap(async (req, res) => {
  const n = Number(req.body?.quantity);
  if (!Number.isInteger(n) || n < 0) return fail(res, 400, 'Quantity must be zero or a positive integer');
  if (n === 0) { await db.query('DELETE FROM CartItems WHERE userId = ? AND bookId = ?', [req.user.id, req.params.bookId]); return res.json({ message: 'Item removed' }); }
  const [books] = await db.query('SELECT stockQuantity FROM Books WHERE id = ?', [req.params.bookId]);
  if (!books[0]) return fail(res, 404, 'Book not found');
  if (n > books[0].stockQuantity) return fail(res, 409, 'Requested quantity exceeds available stock');
  const [result] = await db.query('UPDATE CartItems SET quantity = ? WHERE userId = ? AND bookId = ?', [n, req.user.id, req.params.bookId]);
  return result.affectedRows ? res.json({ message: 'Cart updated' }) : fail(res, 404, 'Cart item not found');
 }));
 app.delete('/api/cart/items/:bookId', customer, wrap(async (req, res) => { await db.query('DELETE FROM CartItems WHERE userId = ? AND bookId = ?', [req.user.id, req.params.bookId]); res.status(204).end(); }));
 app.delete('/api/cart', customer, wrap(async (req, res) => { await db.query('DELETE FROM CartItems WHERE userId = ?', [req.user.id]); res.status(204).end(); }));
 app.get('/api/wishlist', customer, wrap(async (req, res) => {
  const [rows] = await db.query(`SELECT ${BOOK_COLS} FROM WishlistItems w JOIN Books b ON b.id = w.bookId ${BOOK_JOINS} WHERE w.userId = ? ORDER BY w.createdAt DESC`, [req.user.id]);
  res.json({ items: rows.map(mapBook) });
 }));
 app.post('/api/wishlist/:bookId', customer, wrap(async (req, res) => {
  const [books] = await db.query('SELECT id FROM Books WHERE id = ?', [req.params.bookId]);
  if (!books[0]) return fail(res, 404, 'Book not found');
  await db.query('INSERT IGNORE INTO WishlistItems (userId, bookId) VALUES (?,?)', [req.user.id, books[0].id]);
  res.status(201).json({ message: 'Added to wishlist' });
 }));
 app.delete('/api/wishlist/:bookId', customer, wrap(async (req, res) => { await db.query('DELETE FROM WishlistItems WHERE userId = ? AND bookId = ?', [req.user.id, req.params.bookId]); res.status(204).end(); }));

 app.post('/api/orders', customer, wrap(async (req, res) => {
  const { customerName, phone, address, city, paymentMethod, state = '', country = 'Nigeria' } = req.body || {};
  if (![customerName, phone, address, city, paymentMethod].every(v => typeof v === 'string' && v.trim())) return fail(res, 400, 'Customer name, phone, address, city, and payment method are required');
  try {
   const orderId = await tx(async conn => {
    const [items] = await conn.query('SELECT c.quantity, b.id, b.title, b.price, b.stockQuantity FROM CartItems c JOIN Books b ON b.id = c.bookId WHERE c.userId = ? FOR UPDATE', [req.user.id]);
    if (!items.length) throw Object.assign(new Error('Cart is empty'), { status: 400 });
    for (const item of items) if (item.quantity > item.stockQuantity) throw Object.assign(new Error(`Insufficient stock for ${item.title}`), { status: 409 });
    const subtotal = items.reduce((sum, item) => sum + Number(item.price) * item.quantity, 0), total = subtotal + DELIVERY_FEE;
    const [order] = await conn.query(
     'INSERT INTO Orders (userId,totalAmount,shippingName,shippingPhone,shippingStreet,shippingCity,shippingState,shippingCountry) VALUES (?,?,?,?,?,?,?,?)',
     [req.user.id, total, customerName.trim(), phone.trim(), address.trim(), city.trim(), String(state).trim(), String(country).trim()]);
    for (const item of items) await conn.query('INSERT INTO OrderItems (orderId,bookId,title,quantity,price) VALUES (?,?,?,?,?)', [order.insertId, item.id, item.title, item.quantity, item.price]);
    await conn.query('INSERT INTO Payments (orderId,amount,method) VALUES (?,?,?)', [order.insertId, total, paymentToDb(paymentMethod)]);
    await conn.query('DELETE FROM CartItems WHERE userId = ?', [req.user.id]);
    return order.insertId;
   });
   const [rows] = await db.query('SELECT * FROM Orders WHERE id = ?', [orderId]);
   res.status(201).json({ order: await mapOrder(rows[0]) });
  } catch (error) {
   if (error.status) return fail(res, error.status, error.message);
   if (error.code === 'ER_SIGNAL_EXCEPTION') return fail(res, 409, error.sqlMessage || 'Not enough stock for this book');
   throw error;
  }
 }));
 app.get('/api/orders', customer, wrap(async (req, res) => {
  const [rows] = await db.query('SELECT * FROM Orders WHERE userId = ? ORDER BY createdAt DESC, id DESC', [req.user.id]);
  res.json({ items: await Promise.all(rows.map(mapOrder)) });
 }));
 app.get('/api/orders/:id', customer, wrap(async (req, res) => {
  const [rows] = await db.query('SELECT * FROM Orders WHERE id = ? AND userId = ?', [req.params.id, req.user.id]);
  return rows[0] ? res.json({ order: await mapOrder(rows[0]) }) : fail(res, 404, 'Order not found');
 }));


 app.get('/api/admin/summary', admin, wrap(async (_req, res) => {
  const [[books]] = await db.query('SELECT COUNT(*) AS count, COALESCE(SUM(stockQuantity),0) AS inventory FROM Books');
  const [[users]] = await db.query("SELECT COUNT(*) AS count FROM Users WHERE role = 'USER'");
  const [[orders]] = await db.query("SELECT COUNT(*) AS count, COALESCE(SUM(CASE WHEN status <> 'CANCELLED' THEN totalAmount ELSE 0 END),0) AS revenue FROM Orders");
  const [[pending]] = await db.query("SELECT COUNT(*) AS count FROM Orders WHERE status IN ('PENDING','PAID','PROCESSING')");
  res.json({ books: books.count, inventory: Number(books.inventory), customers: users.count, orders: orders.count, revenue: Number(orders.revenue), pendingOrders: pending.count });
 }));
 app.post('/api/admin/books', admin, wrap(async (req, res) => {
  const issue = validateBook(req.body); if (issue) return fail(res, 400, issue);
  const b = req.body;
  const id = await tx(async conn => {
   const authorId = await idByName(conn, 'Authors', b.author.trim()), genreId = await idByName(conn, 'Genres', b.genre.trim());
   const [result] = await conn.query(
    'INSERT INTO Books (title,authorId,description,imageUrl,price,releaseDate,stockQuantity,isBestseller,isNewArrival,isFeatured) VALUES (?,?,?,?,?,CURDATE(),?,?,?,?)',
    [b.title.trim(), authorId, b.description || '', b.coverUrl || '', Number(b.price), Number(b.stock), flag(b.isBestseller), flag(b.isNewArrival), flag(b.isFeatured)]);
   await conn.query('INSERT INTO BookGenres (bookId, genreId) VALUES (?,?)', [result.insertId, genreId]);
   return result.insertId;
  });
  res.status(201).json({ book: await getBook(id) });
 }));
 app.patch('/api/admin/books/:id', admin, wrap(async (req, res) => {
  const old = await getBook(req.params.id); if (!old) return fail(res, 404, 'Book not found');
  const issue = validateBook(req.body || {}, true); if (issue) return fail(res, 400, issue);
  const m = { ...old, ...(req.body || {}) };
  await tx(async conn => {
   const authorId = await idByName(conn, 'Authors', m.author.trim());
   await conn.query('UPDATE Books SET title=?,authorId=?,description=?,imageUrl=?,price=?,stockQuantity=?,isBestseller=?,isNewArrival=?,isFeatured=? WHERE id=?',
    [m.title.trim(), authorId, m.description || '', m.coverUrl || '', Number(m.price), Number(m.stock), flag(m.isBestseller), flag(m.isNewArrival), flag(m.isFeatured), req.params.id]);
   if (req.body?.genre !== undefined && m.genre.trim().toLowerCase() !== (old.genre || '').toLowerCase()) {
    const genreId = await idByName(conn, 'Genres', m.genre.trim());
    await conn.query('DELETE FROM BookGenres WHERE bookId = ?', [req.params.id]);
    await conn.query('INSERT INTO BookGenres (bookId, genreId) VALUES (?,?)', [req.params.id, genreId]);
   }
  });
  res.json({ book: await getBook(req.params.id) });
 }));
 app.delete('/api/admin/books/:id', admin, wrap(async (req, res) => {
  const [result] = await db.query('DELETE FROM Books WHERE id = ?', [req.params.id]);
  return result.affectedRows ? res.status(204).end() : fail(res, 404, 'Book not found');
 }));
 app.get('/api/admin/orders', admin, wrap(async (req, res) => {
  const status = STATUS_TO_DB[req.query.status];
  const [rows] = status ? await db.query('SELECT * FROM Orders WHERE status = ? ORDER BY createdAt DESC, id DESC', [status]) : await db.query('SELECT * FROM Orders ORDER BY createdAt DESC, id DESC');
  res.json({ items: await Promise.all(rows.map(mapOrder)) });
 }));
 app.patch('/api/admin/orders/:id/status', admin, wrap(async (req, res) => {
  const status = req.body?.status;
  if (!STATUS_TO_DB[status]) return fail(res, 400, `status must be one of: ${Object.keys(STATUS_TO_DB).join(', ')}`);
  const [result] = await db.query('UPDATE Orders SET status = ? WHERE id = ?', [STATUS_TO_DB[status], req.params.id]);
  if (!result.affectedRows) return fail(res, 404, 'Order not found');
  const [rows] = await db.query('SELECT * FROM Orders WHERE id = ?', [req.params.id]);
  res.json({ order: await mapOrder(rows[0]) });
 }));
 app.get('/api/admin/users', admin, wrap(async (req, res) => {
  const q = `%${String(req.query.q || '').toLowerCase()}%`;
  const [rows] = await db.query("SELECT id,name,email,phone,role,disabled,createdAt FROM Users WHERE role = 'USER' AND (LOWER(name) LIKE ? OR LOWER(email) LIKE ? OR phone LIKE ?) ORDER BY createdAt DESC, id DESC", [q, q, q]);
  res.json({ items: rows.map(u => ({ ...publicUser(u), disabled: !!u.disabled })) });
 }));
 app.patch('/api/admin/users/:id/status', admin, wrap(async (req, res) => {
  if (typeof req.body?.disabled !== 'boolean') return fail(res, 400, 'disabled must be a boolean');
  const [result] = await db.query("UPDATE Users SET disabled = ? WHERE id = ? AND role = 'USER'", [req.body.disabled ? 1 : 0, req.params.id]);
  return result.affectedRows ? res.json({ message: 'User status updated' }) : fail(res, 404, 'Customer not found');
 }));
 app.delete('/api/admin/users/:id', admin, wrap(async (req, res) => {
  try {
   const deleted = await tx(async conn => {
    await conn.query("DELETE FROM Reviews WHERE userId IN (SELECT id FROM (SELECT id FROM Users WHERE id = ? AND role = 'USER') AS u)", [req.params.id]);
    const [result] = await conn.query("DELETE FROM Users WHERE id = ? AND role = 'USER'", [req.params.id]);
    return result.affectedRows;
   });
   return deleted ? res.status(204).end() : fail(res, 404, 'Customer not found');
  } catch (error) {
   if (error.code === 'ER_ROW_IS_REFERENCED_2') return fail(res, 409, 'This customer has orders and cannot be deleted. Disable the account instead.');
   throw error;
  }
 }));

 app.use((_req, res) => fail(res, 404, 'Route not found'));
 app.use((err, _req, res, _next) => {
  if (err.code === 'ER_DUP_ENTRY') return fail(res, 409, 'That value already exists');
  if (err.code === 'ER_NO_REFERENCED_ROW_2') return fail(res, 400, 'Invalid reference (check the book, author or genre)');
  if (err.code === 'ER_SIGNAL_EXCEPTION') return fail(res, 409, err.sqlMessage || 'Request refused by the database');
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
 });

 return { app, db, bcrypt, tokenFor };
};

module.exports = createApp;