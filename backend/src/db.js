const fs = require('node:fs');
const path = require('node:path');
const Database = require('better-sqlite3');

const file = process.env.DATABASE_FILE || path.join(__dirname, '../data/shelfspace.sqlite');
if (file !== ':memory:') fs.mkdirSync(path.dirname(path.resolve(file)), { recursive: true });
const db = new Database(file);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');
db.exec(`
CREATE TABLE IF NOT EXISTS users (
 id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE COLLATE NOCASE,
 password_hash TEXT NOT NULL, phone TEXT NOT NULL DEFAULT '', role TEXT NOT NULL DEFAULT 'customer',
 disabled INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS books (
 id TEXT PRIMARY KEY, title TEXT NOT NULL, author TEXT NOT NULL, genre TEXT NOT NULL,
 description TEXT NOT NULL DEFAULT '', cover_url TEXT NOT NULL DEFAULT '', price REAL NOT NULL CHECK(price >= 0),
 stock INTEGER NOT NULL DEFAULT 0 CHECK(stock >= 0), rating REAL NOT NULL DEFAULT 0,
 review_count INTEGER NOT NULL DEFAULT 0, bestseller INTEGER NOT NULL DEFAULT 0,
 new_arrival INTEGER NOT NULL DEFAULT 0, featured INTEGER NOT NULL DEFAULT 0,
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS cart_items (
 user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
 quantity INTEGER NOT NULL CHECK(quantity > 0), PRIMARY KEY(user_id, book_id)
);
CREATE TABLE IF NOT EXISTS wishlist_items (
 user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(user_id, book_id)
);
CREATE TABLE IF NOT EXISTS orders (
 id TEXT PRIMARY KEY, user_id TEXT REFERENCES users(id) ON DELETE SET NULL, customer_name TEXT NOT NULL,
 phone TEXT NOT NULL, address TEXT NOT NULL, city TEXT NOT NULL, payment_method TEXT NOT NULL,
 subtotal REAL NOT NULL, delivery_fee REAL NOT NULL, total REAL NOT NULL,
 status TEXT NOT NULL DEFAULT 'Processing', created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS order_items (
 id INTEGER PRIMARY KEY AUTOINCREMENT, order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
 book_id TEXT, title TEXT NOT NULL, author TEXT NOT NULL, cover_url TEXT NOT NULL,
 unit_price REAL NOT NULL, quantity INTEGER NOT NULL, total_price REAL NOT NULL
);
CREATE TABLE IF NOT EXISTS reviews (
 id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE, rating INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
 comment TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE(user_id, book_id)
);
CREATE TABLE IF NOT EXISTS password_resets (
 id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 token_hash TEXT NOT NULL, expires_at INTEGER NOT NULL, used INTEGER NOT NULL DEFAULT 0
);
`);

const initialBooks = [
 ['1','The Silent Patient','Alex Michaelides','Thriller','A psychological thriller about a woman whose refusal to speak after a shocking crime captures the attention of a determined therapist.','https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=600',8500,12,4.7,1240,1,0,1],
 ['2','Atomic Habits','James Clear','Self Development','A practical guide to building good habits, breaking bad ones, and making small changes that create remarkable results.','https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=600',7200,3,4.8,2480,1,0,0],
 ['3','The Great Gatsby','F. Scott Fitzgerald','Classic','A classic American novel exploring ambition, love, wealth, and the American dream.','https://images.unsplash.com/photo-1511108690759-009324a90311?w=600',5500,8,4.5,890,1,0,0],
 ['4','The Alchemist','Paulo Coelho','Fiction','A philosophical story about following your dreams and discovering your purpose.','https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600',6000,2,4.7,1760,0,1,0],
 ['5','Ikigai','Hector Garcia','Lifestyle','A guide to discovering the Japanese concept of purpose and living a more meaningful life.','https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600',6800,4,4.6,940,0,1,0]
];
const count = db.prepare('SELECT COUNT(*) n FROM books').get().n;
if (!count) {
 const insert = db.prepare(`INSERT INTO books (id,title,author,genre,description,cover_url,price,stock,rating,review_count,bestseller,new_arrival,featured) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`);
 const seed = db.transaction(rows => rows.forEach(row => insert.run(...row)));
 seed(initialBooks);
}

module.exports = db;
