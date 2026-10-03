require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { randomUUID, createHash } = require('node:crypto');
const db = require('./db');

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
 throw new Error('JWT_SECRET must be set to a random secret of at least 32 characters');
}
const app = express();
app.disable('x-powered-by');
const allowedOrigins = process.env.CLIENT_ORIGIN?.split(',').map(value => value.trim()).filter(Boolean);
app.use(cors({ origin: allowedOrigins ? (origin, callback) => {
 if (!origin || allowedOrigins.some(pattern => pattern === '*' || (pattern.includes('*') && new RegExp(`^${pattern.split('*').map(part => part.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('.*')}$`).test(origin)) || pattern === origin)) return callback(null, true);
 callback(new Error('Origin is not allowed by CORS'));
} : true }));
app.use(express.json({ limit: '1mb' }));
app.use('/api/auth', rateLimit({ windowMs: 15 * 60 * 1000, limit: 30, standardHeaders: true, legacyHeaders: false }));

const bool = value => value === true || value === 1 || value === 'true';
function mapBook(row) {
 return { id: row.id, title: row.title, author: row.author, genre: row.genre, description: row.description,
  coverUrl: row.cover_url, price: row.price, stock: row.stock, rating: row.rating, reviewCount: row.review_count,
  isBestseller: !!row.bestseller, isNewArrival: !!row.new_arrival, isFeatured: !!row.featured };
}
function mapOrder(row) {
 const items = db.prepare('SELECT * FROM order_items WHERE order_id = ?').all(row.id).map(item => ({
  bookId: item.book_id, title: item.title, author: item.author, coverUrl: item.cover_url,
  unitPrice: item.unit_price, quantity: item.quantity, totalPrice: item.total_price
 }));
 return { id: row.id, items, subtotal: row.subtotal, deliveryFee: row.delivery_fee, total: row.total,
  customerName: row.customer_name, phone: row.phone, address: row.address, city: row.city,
  paymentMethod: row.payment_method, createdAt: row.created_at, status: row.status };
}
function fail(res, status, message) { return res.status(status).json({ error: message }); }
function auth(requiredRole) {
 return (req, res, next) => {
  const token = (req.headers.authorization || '').replace(/^Bearer\s+/i, '');
  try {
   if (!token) return fail(res, 401, 'Authentication required');
   const claims = jwt.verify(token, process.env.JWT_SECRET);
   const user = db.prepare('SELECT id,name,email,phone,role,disabled FROM users WHERE id=?').get(claims.sub);
   if (!user || user.disabled) return fail(res, 401, 'Account unavailable');
   if (requiredRole && user.role !== requiredRole) return fail(res, 403, 'Admin access required');
   req.user = user; next();
  } catch { return fail(res, 401, 'Invalid or expired token'); }
 };
}
const customer = auth();
const admin = auth('admin');
function tokenFor(user) { return jwt.sign({ sub: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' }); }
function publicUser(user) { return { id: user.id, name: user.name, email: user.email, phone: user.phone, role: user.role, createdAt: user.created_at }; }
function validateBook(body, partial = false) {
 const fields = ['title','author','genre','description','coverUrl','price','stock'];
 for (const key of fields) if (!partial || body[key] !== undefined) {
  const value = body[key];
  if (['title','author','genre'].includes(key) && (typeof value !== 'string' || !value.trim())) return `${key} is required`;
  if (key === 'price' && (!Number.isFinite(Number(value)) || Number(value) < 0)) return 'price must be zero or greater';
  if (key === 'stock' && (!Number.isInteger(Number(value)) || Number(value) < 0)) return 'stock must be a non-negative integer';
  if (['description','coverUrl'].includes(key) && value != null && typeof value !== 'string') return `${key} must be a string`;
 }
 return null;
}
function bookValues(body) {
 return [body.title.trim(),body.author.trim(),body.genre.trim(),body.description || '',body.coverUrl || '',Number(body.price),Number(body.stock),bool(body.isBestseller)?1:0,bool(body.isNewArrival)?1:0,bool(body.isFeatured)?1:0];
}

app.get('/api/health', (_req,res) => res.json({ status:'ok', service:'shelfspace-api' }));

// Authentication and profile
app.post('/api/auth/register', async (req,res,next) => {
 try {
  const { name,email,password,phone='' } = req.body || {};
  if (typeof name !== 'string' || name.trim().length < 2 || typeof email !== 'string' || !/^\S+@\S+\.\S+$/.test(email) || typeof password !== 'string' || password.length < 8) return fail(res,400,'Provide a name, valid email, and password of at least 8 characters');
  const id = randomUUID(), passwordHash = await bcrypt.hash(password,12);
  db.prepare('INSERT INTO users(id,name,email,password_hash,phone) VALUES(?,?,?,?,?)').run(id,name.trim(),email.trim().toLowerCase(),passwordHash,String(phone).trim());
  const user = db.prepare('SELECT * FROM users WHERE id=?').get(id);
  res.status(201).json({ user:publicUser(user), token:tokenFor(user) });
 } catch (e) { if (e.code === 'SQLITE_CONSTRAINT_UNIQUE') return fail(res,409,'Email is already registered'); next(e); }
});
app.post('/api/auth/login', async (req,res,next) => {
 try {
  const email = String(req.body?.email || '').trim().toLowerCase(), password = req.body?.password;
  const user = db.prepare('SELECT * FROM users WHERE email=?').get(email);
  if (!user || !await bcrypt.compare(String(password || ''),user.password_hash)) return fail(res,401,'Email or password is incorrect');
  if (user.disabled) return fail(res,403,'Account is disabled');
  res.json({ user:publicUser(user), token:tokenFor(user) });
 } catch(e) { next(e); }
});
app.get('/api/auth/me', customer, (req,res) => res.json({ user:req.user }));
app.patch('/api/auth/me', customer, (req,res,next) => {
 try {
  const { name,phone } = req.body || {};
  if (name !== undefined && (typeof name !== 'string' || name.trim().length < 2)) return fail(res,400,'Name must contain at least 2 characters');
  if (phone !== undefined && typeof phone !== 'string') return fail(res,400,'Phone must be a string');
  db.prepare('UPDATE users SET name=COALESCE(?,name),phone=COALESCE(?,phone) WHERE id=?').run(name?.trim() ?? null,phone?.trim() ?? null,req.user.id);
  res.json({ user:db.prepare('SELECT id,name,email,phone,role,created_at FROM users WHERE id=?').get(req.user.id) });
 } catch(e) { next(e); }
});
app.post('/api/auth/change-password', customer, async (req,res,next) => {
 try {
  const { currentPassword,newPassword } = req.body || {};
  const row = db.prepare('SELECT password_hash FROM users WHERE id=?').get(req.user.id);
  if (!await bcrypt.compare(String(currentPassword || ''),row.password_hash)) return fail(res,400,'Current password is incorrect');
  if (typeof newPassword !== 'string' || newPassword.length < 8) return fail(res,400,'New password must be at least 8 characters');
  db.prepare('UPDATE users SET password_hash=? WHERE id=?').run(await bcrypt.hash(newPassword,12),req.user.id);
  res.json({ message:'Password updated' });
 } catch(e) { next(e); }
});
// Password reset uses a one-time token. In production, deliver it by email through a mail provider.
app.post('/api/auth/forgot-password', (req,res,next) => {
 try {
  const email = String(req.body?.email || '').trim().toLowerCase(), user = db.prepare('SELECT id FROM users WHERE email=?').get(email);
  if (user) { const raw = require('node:crypto').randomBytes(32).toString('hex');
   db.prepare('INSERT INTO password_resets(id,user_id,token_hash,expires_at) VALUES(?,?,?,?)').run(randomUUID(),user.id,createHash('sha256').update(raw).digest('hex'),Date.now()+3600000);
   if (process.env.NODE_ENV !== 'production') res.locals.resetToken = raw;
  }
  const response = { message:'If the account exists, password reset instructions have been sent' };
  if (res.locals.resetToken) response.developmentResetToken = res.locals.resetToken;
  res.json(response);
 } catch(e) { next(e); }
});
app.post('/api/auth/reset-password', async (req,res,next) => {
 try {
  const { token,newPassword } = req.body || {};
  if (typeof newPassword !== 'string' || newPassword.length < 8) return fail(res,400,'Password must be at least 8 characters');
  const hash = createHash('sha256').update(String(token || '')).digest('hex');
  const reset = db.prepare('SELECT * FROM password_resets WHERE token_hash=? AND used=0 AND expires_at>?').get(hash,Date.now());
  if (!reset) return fail(res,400,'Reset token is invalid or expired');
  const passwordHash = await bcrypt.hash(newPassword,12);
  db.transaction(() => { db.prepare('UPDATE users SET password_hash=? WHERE id=?').run(passwordHash,reset.user_id); db.prepare('UPDATE password_resets SET used=1 WHERE id=?').run(reset.id); })();
  res.json({ message:'Password reset successfully' });
 } catch(e) { next(e); }
});

// Public catalog and reviews
app.get('/api/books', (req,res) => {
 const { q,genre,featured,bestseller,newArrival,sort='newest',page='1',limit='24' } = req.query;
 const where=[], values=[];
 if (q) { where.push('(title LIKE ? OR author LIKE ? OR genre LIKE ?)'); values.push(`%${q}%`,`%${q}%`,`%${q}%`); }
 if (genre) { where.push('genre = ? COLLATE NOCASE'); values.push(genre); }
 for (const [param,col] of [['featured','featured'],['bestseller','bestseller'],['newArrival','new_arrival']]) if (req.query[param] !== undefined) { where.push(`${col}=?`); values.push(bool(req.query[param])?1:0); }
 const order={newest:'created_at DESC',price_asc:'price ASC',price_desc:'price DESC',rating:'rating DESC',title:'title COLLATE NOCASE ASC'}[sort] || 'created_at DESC';
 const p=Math.max(1,parseInt(page,10)||1), n=Math.min(100,Math.max(1,parseInt(limit,10)||24)), filter=where.length?`WHERE ${where.join(' AND ')}`:'';
 const total=db.prepare(`SELECT COUNT(*) n FROM books ${filter}`).get(...values).n;
 const rows=db.prepare(`SELECT * FROM books ${filter} ORDER BY ${order} LIMIT ? OFFSET ?`).all(...values,n,(p-1)*n);
 res.json({ items:rows.map(mapBook), page:p, limit:n, total, pages:Math.ceil(total/n) });
});
app.get('/api/books/:id', (req,res) => { const row=db.prepare('SELECT * FROM books WHERE id=?').get(req.params.id); return row?res.json({book:mapBook(row)}):fail(res,404,'Book not found'); });
app.get('/api/books/:id/reviews', (req,res) => {
 const rows=db.prepare('SELECT r.id,r.rating,r.comment,r.created_at,u.name AS customerName FROM reviews r JOIN users u ON u.id=r.user_id WHERE r.book_id=? ORDER BY r.created_at DESC').all(req.params.id);
 res.json({items:rows});
});
app.post('/api/books/:id/reviews', customer, (req,res,next) => {
 try {
  const rating=Number(req.body?.rating), comment=String(req.body?.comment||'').trim();
  if (!Number.isInteger(rating)||rating<1||rating>5) return fail(res,400,'Rating must be an integer from 1 to 5');
  if (!db.prepare('SELECT 1 FROM books WHERE id=?').get(req.params.id)) return fail(res,404,'Book not found');
  const id=randomUUID();
  db.prepare('INSERT INTO reviews(id,user_id,book_id,rating,comment) VALUES(?,?,?,?,?)').run(id,req.user.id,req.params.id,rating,comment);
  db.prepare('UPDATE books SET rating=(SELECT AVG(rating) FROM reviews WHERE book_id=?),review_count=(SELECT COUNT(*) FROM reviews WHERE book_id=?) WHERE id=?').run(req.params.id,req.params.id,req.params.id);
  res.status(201).json({id,rating,comment});
 } catch(e) { if(e.code==='SQLITE_CONSTRAINT_UNIQUE') return fail(res,409,'You have already reviewed this book'); next(e); }
});

// User cart and wishlist
app.get('/api/cart', customer, (req,res) => { const items=db.prepare('SELECT c.quantity,b.* FROM cart_items c JOIN books b ON b.id=c.book_id WHERE c.user_id=? ORDER BY b.title').all(req.user.id).map(row=>({book:mapBook(row),quantity:row.quantity})); res.json({items,subtotal:items.reduce((s,i)=>s+i.book.price*i.quantity,0)}); });
app.post('/api/cart/items', customer, (req,res,next) => {
 try { const id=String(req.body?.bookId||''), quantity=Number(req.body?.quantity??1);
  if(!Number.isInteger(quantity)||quantity<1) return fail(res,400,'Quantity must be a positive integer');
  const book=db.prepare('SELECT * FROM books WHERE id=?').get(id); if(!book) return fail(res,404,'Book not found');
  const old=db.prepare('SELECT quantity FROM cart_items WHERE user_id=? AND book_id=?').get(req.user.id,id)?.quantity||0;
  if(old+quantity>book.stock) return fail(res,409,'Requested quantity exceeds available stock');
  db.prepare('INSERT INTO cart_items(user_id,book_id,quantity) VALUES(?,?,?) ON CONFLICT(user_id,book_id) DO UPDATE SET quantity=excluded.quantity').run(req.user.id,id,old+quantity);
  res.status(201).json({message:'Item added to cart'});
 } catch(e){next(e);}
});
app.patch('/api/cart/items/:bookId', customer, (req,res) => {
 const n=Number(req.body?.quantity), book=db.prepare('SELECT stock FROM books WHERE id=?').get(req.params.bookId);
 if(!Number.isInteger(n)||n<0) return fail(res,400,'Quantity must be zero or a positive integer');
 if(n===0){db.prepare('DELETE FROM cart_items WHERE user_id=? AND book_id=?').run(req.user.id,req.params.bookId);return res.json({message:'Item removed'});}
 if(!book) return fail(res,404,'Book not found'); if(n>book.stock) return fail(res,409,'Requested quantity exceeds available stock');
 const result=db.prepare('UPDATE cart_items SET quantity=? WHERE user_id=? AND book_id=?').run(n,req.user.id,req.params.bookId);
 return result.changes?res.json({message:'Cart updated'}):fail(res,404,'Cart item not found');
});
app.delete('/api/cart/items/:bookId', customer, (req,res) => { db.prepare('DELETE FROM cart_items WHERE user_id=? AND book_id=?').run(req.user.id,req.params.bookId); res.status(204).end(); });
app.delete('/api/cart', customer, (req,res) => { db.prepare('DELETE FROM cart_items WHERE user_id=?').run(req.user.id); res.status(204).end(); });
app.get('/api/wishlist', customer, (req,res) => { const items=db.prepare('SELECT b.* FROM wishlist_items w JOIN books b ON b.id=w.book_id WHERE w.user_id=? ORDER BY w.created_at DESC').all(req.user.id).map(mapBook); res.json({items}); });
app.post('/api/wishlist/:bookId', customer, (req,res) => { if(!db.prepare('SELECT 1 FROM books WHERE id=?').get(req.params.bookId))return fail(res,404,'Book not found'); db.prepare('INSERT OR IGNORE INTO wishlist_items(user_id,book_id) VALUES(?,?)').run(req.user.id,req.params.bookId); res.status(201).json({message:'Added to wishlist'}); });
app.delete('/api/wishlist/:bookId', customer, (req,res) => { db.prepare('DELETE FROM wishlist_items WHERE user_id=? AND book_id=?').run(req.user.id,req.params.bookId); res.status(204).end(); });

// Checkout re-reads prices and stock inside one database transaction.
app.post('/api/orders', customer, (req,res,next) => {
 try {
  const {customerName,phone,address,city,paymentMethod}=req.body||{};
  if(![customerName,phone,address,city,paymentMethod].every(v=>typeof v==='string'&&v.trim()))return fail(res,400,'Customer name, phone, address, city, and payment method are required');
  const id=`BIB-${Date.now()}-${randomUUID().slice(0,8)}`;
  const create=db.transaction(()=>{
   const items=db.prepare('SELECT c.quantity,b.* FROM cart_items c JOIN books b ON b.id=c.book_id WHERE c.user_id=?').all(req.user.id);
   if(!items.length)throw Object.assign(new Error('Cart is empty'),{status:400});
   for(const item of items)if(item.quantity>item.stock)throw Object.assign(new Error(`Insufficient stock for ${item.title}`),{status:409});
   const subtotal=items.reduce((sum,i)=>sum+i.price*i.quantity,0),deliveryFee=1500;
   db.prepare('INSERT INTO orders(id,user_id,customer_name,phone,address,city,payment_method,subtotal,delivery_fee,total) VALUES(?,?,?,?,?,?,?,?,?,?)').run(id,req.user.id,customerName.trim(),phone.trim(),address.trim(),city.trim(),paymentMethod.trim(),subtotal,deliveryFee,subtotal+deliveryFee);
   const save=db.prepare('INSERT INTO order_items(order_id,book_id,title,author,cover_url,unit_price,quantity,total_price) VALUES(?,?,?,?,?,?,?,?)');
   const stock=db.prepare('UPDATE books SET stock=stock-? WHERE id=?');
   for(const i of items){save.run(id,i.id,i.title,i.author,i.cover_url,i.price,i.quantity,i.price*i.quantity);stock.run(i.quantity,i.id);}
   db.prepare('DELETE FROM cart_items WHERE user_id=?').run(req.user.id);
   return db.prepare('SELECT * FROM orders WHERE id=?').get(id);
  });
  const order=create();res.status(201).json({order:mapOrder(order)});
 }catch(e){if(e.status)return fail(res,e.status,e.message);next(e);}
});
app.get('/api/orders', customer, (req,res) => { const rows=db.prepare('SELECT * FROM orders WHERE user_id=? ORDER BY created_at DESC').all(req.user.id); res.json({items:rows.map(mapOrder)}); });
app.get('/api/orders/:id', customer, (req,res) => { const row=db.prepare('SELECT * FROM orders WHERE id=? AND user_id=?').get(req.params.id,req.user.id); return row?res.json({order:mapOrder(row)}):fail(res,404,'Order not found'); });

// Admin operations
app.get('/api/admin/summary', admin, (_req,res) => {
 const books=db.prepare('SELECT COUNT(*) count,COALESCE(SUM(stock),0) inventory FROM books').get();
 const users=db.prepare("SELECT COUNT(*) count FROM users WHERE role='customer'").get();
 const orders=db.prepare('SELECT COUNT(*) count,COALESCE(SUM(total),0) revenue FROM orders').get();
 const pending=db.prepare("SELECT COUNT(*) count FROM orders WHERE status IN ('Processing','Confirmed')").get();
 res.json({books:books.count,inventory:books.inventory,customers:users.count,orders:orders.count,revenue:orders.revenue,pendingOrders:pending.count});
});
app.post('/api/admin/books', admin, (req,res,next) => { try { const issue=validateBook(req.body);if(issue)return fail(res,400,issue);const id=randomUUID(),v=bookValues(req.body);db.prepare('INSERT INTO books(id,title,author,genre,description,cover_url,price,stock,bestseller,new_arrival,featured) VALUES(?,?,?,?,?,?,?,?,?,?,?)').run(id,...v);res.status(201).json({book:mapBook(db.prepare('SELECT * FROM books WHERE id=?').get(id))}); }catch(e){next(e);} });
app.patch('/api/admin/books/:id', admin, (req,res,next) => { try { const old=db.prepare('SELECT * FROM books WHERE id=?').get(req.params.id);if(!old)return fail(res,404,'Book not found');const patch=req.body||{}, merged={title:old.title,author:old.author,genre:old.genre,description:old.description,coverUrl:old.cover_url,price:old.price,stock:old.stock,isBestseller:!!old.bestseller,isNewArrival:!!old.new_arrival,isFeatured:!!old.featured,...patch};const issue=validateBook(merged);if(issue)return fail(res,400,issue);const v=bookValues(merged);db.prepare('UPDATE books SET title=?,author=?,genre=?,description=?,cover_url=?,price=?,stock=?,bestseller=?,new_arrival=?,featured=?,updated_at=CURRENT_TIMESTAMP WHERE id=?').run(...v,req.params.id);res.json({book:mapBook(db.prepare('SELECT * FROM books WHERE id=?').get(req.params.id))}); }catch(e){next(e);} });
app.delete('/api/admin/books/:id', admin, (req,res) => { const out=db.prepare('DELETE FROM books WHERE id=?').run(req.params.id);return out.changes?res.status(204).end():fail(res,404,'Book not found'); });
app.get('/api/admin/orders', admin, (req,res) => { const status=req.query.status;const rows=status?db.prepare('SELECT * FROM orders WHERE status=? ORDER BY created_at DESC').all(status):db.prepare('SELECT * FROM orders ORDER BY created_at DESC').all();res.json({items:rows.map(mapOrder)}); });
app.patch('/api/admin/orders/:id/status', admin, (req,res) => { const allowed=['Processing','Confirmed','Shipped','Delivered','Cancelled'];const status=req.body?.status;if(!allowed.includes(status))return fail(res,400,`status must be one of: ${allowed.join(', ')}`);const out=db.prepare('UPDATE orders SET status=? WHERE id=?').run(status,req.params.id);return out.changes?res.json({order:mapOrder(db.prepare('SELECT * FROM orders WHERE id=?').get(req.params.id))}):fail(res,404,'Order not found'); });
app.get('/api/admin/users', admin, (req,res) => { const q=String(req.query.q||'').toLowerCase();const rows=db.prepare("SELECT id,name,email,phone,role,disabled,created_at FROM users WHERE role='customer' AND (lower(name) LIKE ? OR lower(email) LIKE ? OR phone LIKE ?) ORDER BY created_at DESC").all(`%${q}%`,`%${q}%`,`%${q}%`);res.json({items:rows.map(u=>({...u,disabled:!!u.disabled}))}); });
app.patch('/api/admin/users/:id/status', admin, (req,res) => { if(typeof req.body?.disabled!=='boolean')return fail(res,400,'disabled must be a boolean');const out=db.prepare("UPDATE users SET disabled=? WHERE id=? AND role='customer'").run(req.body.disabled?1:0,req.params.id);return out.changes?res.json({message:'User status updated'}):fail(res,404,'Customer not found'); });
app.delete('/api/admin/users/:id', admin, (req,res) => { const out=db.prepare("DELETE FROM users WHERE id=? AND role='customer'").run(req.params.id);return out.changes?res.status(204).end():fail(res,404,'Customer not found'); });

app.use((_req,res)=>fail(res,404,'Route not found'));
app.use((err,_req,res,_next)=>{console.error(err);res.status(500).json({error:'Internal server error'});});
module.exports={app,db,bcrypt,tokenFor};
