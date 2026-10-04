const fs = require('node:fs');
const path = require('node:path');
const initSqlJs = require('sql.js');

const file = process.env.DATABASE_FILE || path.join(__dirname, '../data/shelfspace.sqlite');
const dir = path.dirname(path.resolve(file));
if (file !== ':memory:' && !fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

let db;
const initDb = async () => {
  const SQL = await initSqlJs();
  
  // Load existing database or create new one
  if (fs.existsSync(file)) {
    const fileBuffer = fs.readFileSync(file);
    db = new SQL.Database(fileBuffer);
  } else {
    db = new SQL.Database();
  }

  // Enable foreign keys
  db.run('PRAGMA foreign_keys = ON');

  // Create tables
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

  // Seed initial books (converted from seed.sql to match SQLite schema)
  const initialBooks = [
    ['1','Things Fall Apart','Chinua Achebe','Fiction','Okonkwo is a respected leader in an Igbo village until colonial rule and a new religion shake his world.','https://covers.openlibrary.org/b/isbn/9780385474542-L.jpg',4500,40,4.5,180,1,0,1],
    ['2','Half of a Yellow Sun','Chimamanda Ngozi Adichie','Fiction','The lives of three people are tangled together during the Nigerian civil war.','https://covers.openlibrary.org/b/isbn/9781400095209-L.jpg',5500,30,4.7,120,1,0,1],
    ['3','Americanah','Chimamanda Ngozi Adichie','Fiction','A young Nigerian woman moves to America, builds a new life, and later returns to Lagos to face her past love.','https://covers.openlibrary.org/b/isbn/9780307455925-L.jpg',6000,35,4.6,150,1,0,0],
    ['4','Purple Hibiscus','Chimamanda Ngozi Adichie','Fiction','Fifteen-year-old Kambili lives under her strict, religious father until a stay with her aunt shows her another way of living.','https://covers.openlibrary.org/b/isbn/9781616202415-L.jpg',5000,28,4.4,90,0,0,0],
    ['5','Children of Blood and Bone','Tomi Adeyemi','Fantasy','In a land where magic was wiped out, a young girl fights to bring it back and challenge a cruel king.','https://covers.openlibrary.org/b/isbn/9781250170972-L.jpg',7000,25,4.5,95,1,1,1],
    ['6','Stay With Me','Ayobami Adebayo','Fiction','A Nigerian couple faces pressure to have a child, and a secret threatens their marriage.','https://covers.openlibrary.org/b/isbn/9780451494658-L.jpg',5500,20,4.3,60,0,0,0],
    ['7','The Fishermen','Chigozie Obioma','Fiction','Four brothers in a Nigerian town meet a mad prophet whose prediction changes their family forever.','https://covers.openlibrary.org/b/isbn/9780316338387-L.jpg',5500,22,4.2,55,0,0,0],
    ['8','Harry Potter and the Philosopher\'s Stone','J.K. Rowling','Fantasy','An orphan boy learns he is a wizard and begins his first year at Hogwarts School of Witchcraft and Wizardry.','https://covers.openlibrary.org/b/isbn/9780747532743-L.jpg',6500,60,4.8,250,1,0,1],
    ['9','The Hobbit','J.R.R. Tolkien','Fantasy','Bilbo Baggins leaves his quiet home to join dwarves on a journey to win back treasure from a dragon.','https://covers.openlibrary.org/b/isbn/9780547928227-L.jpg',6000,40,4.7,140,1,0,1],
    ['10','The Alchemist','Paulo Coelho','Fiction','A shepherd boy travels from Spain to Egypt in search of treasure and learns to follow his dreams.','https://covers.openlibrary.org/b/isbn/9780062315007-L.jpg',4000,50,4.7,220,1,0,1],
    ['11','To Kill a Mockingbird','Harper Lee','Classic','In a small Southern town, a young girl watches her lawyer father defend a Black man falsely accused of a crime.','https://covers.openlibrary.org/b/isbn/9780061120084-L.jpg',4500,35,4.6,130,1,0,1],
    ['12','1984','George Orwell','Science Fiction','In a country watched by Big Brother, one man risks everything to think and love freely.','https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg',3500,45,4.7,190,1,0,1],
    ['13','Animal Farm','George Orwell','Classic','Farm animals rise up against their owner, but their new leaders soon become as harsh as the old one.','https://covers.openlibrary.org/b/isbn/9780451526342-L.jpg',3000,45,4.5,160,1,0,0],
    ['14','Brave New World','Aldous Huxley','Science Fiction','A future society keeps everyone happy through control and comfort, until one outsider questions it.','https://covers.openlibrary.org/b/isbn/9780060850524-L.jpg',4000,30,4.4,100,0,0,0],
    ['15','Pride and Prejudice','Jane Austen','Romance','Elizabeth Bennet and the proud Mr. Darcy must get past first impressions and class differences to find love.','https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg',3500,40,4.6,170,1,0,1],
    ['16','The Great Gatsby','F. Scott Fitzgerald','Classic','A mysterious millionaire throws lavish parties in the hope of winning back the woman he loved.','https://covers.openlibrary.org/b/isbn/9780743273565-L.jpg',3500,38,4.5,145,1,0,1],
    ['17','The Catcher in the Rye','J.D. Salinger','Classic','Teenager Holden Caulfield wanders New York after leaving school and struggles with growing up.','https://covers.openlibrary.org/b/isbn/9780316769488-L.jpg',4000,25,4.3,85,0,0,0],
    ['18','The Hunger Games','Suzanne Collins','Dystopian','Katniss volunteers to take part in a deadly televised contest in place of her younger sister.','https://covers.openlibrary.org/b/isbn/9780439023528-L.jpg',5000,45,4.6,200,1,1,1],
    ['19','The Da Vinci Code','Dan Brown','Mystery & Thriller','A symbologist and a codebreaker race to solve a murder and a puzzle hidden in famous art.','https://covers.openlibrary.org/b/isbn/9780307474278-L.jpg',5000,30,4.4,135,1,0,0],
    ['20','Gone Girl','Gillian Flynn','Mystery & Thriller','When his wife disappears on their anniversary, a husband becomes the main suspect.','https://covers.openlibrary.org/b/isbn/9780307588371-L.jpg',5000,28,4.3,110,0,0,0],
    ['21','The Girl with the Dragon Tattoo','Stieg Larsson','Mystery & Thriller','A journalist and a skilled hacker investigate a decades-old disappearance in a wealthy Swedish family.','https://covers.openlibrary.org/b/isbn/9780307454546-L.jpg',5500,26,4.5,105,1,0,0],
    ['22','The Kite Runner','Khaled Hosseini','Fiction','A man looks back on his childhood friendship in Afghanistan and the betrayal he spends his life trying to make right.','https://covers.openlibrary.org/b/isbn/9781594631931-L.jpg',5000,32,4.6,125,1,0,1],
    ['23','Life of Pi','Yann Martel','Fiction','A boy survives a shipwreck and spends months on a lifeboat with a Bengal tiger.','https://covers.openlibrary.org/b/isbn/9780156027328-L.jpg',4500,24,4.4,80,0,0,0],
    ['24','Dune','Frank Herbert','Science Fiction','Young Paul Atreides is thrown into a struggle for control of a desert planet and its precious spice.','https://covers.openlibrary.org/b/isbn/9780441172719-L.jpg',6500,30,4.5,115,1,0,1],
    ['25','Atomic Habits','James Clear','Self-Help','A practical guide to building good habits and breaking bad ones through small, steady changes.','https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg',7500,55,4.8,240,1,0,1],
    ['26','Rich Dad Poor Dad','Robert Kiyosaki','Business & Finance','The author compares two views on money and explains how to think about assets, income and investing.','https://covers.openlibrary.org/b/isbn/9781612680194-L.jpg',5000,45,4.5,210,1,0,0],
    ['27','The Psychology of Money','Morgan Housel','Business & Finance','Short stories on how behavior, not just knowledge, shapes the way people save, spend and invest.','https://covers.openlibrary.org/b/isbn/9780857197689-L.jpg',6500,40,4.6,155,1,1,1],
    ['28','Sapiens','Yuval Noah Harari','History','A sweeping look at how humans went from hunter-gatherers to the dominant species on Earth.','https://covers.openlibrary.org/b/isbn/9780062316097-L.jpg',7500,35,4.7,165,1,0,1],
    ['29','Becoming','Michelle Obama','Biography & Memoir','The former First Lady tells her life story, from a childhood in Chicago to the White House.','https://covers.openlibrary.org/b/isbn/9781524763138-L.jpg',8500,30,4.8,175,1,1,1],
    ['30','Educated','Tara Westover','Biography & Memoir','A woman raised by survivalists in rural Idaho teaches herself enough to earn a university degree.','https://covers.openlibrary.org/b/isbn/9780399590504-L.jpg',7000,28,4.6,130,0,1,0]
  ];
  
  const countResult = db.exec('SELECT COUNT(*) as n FROM books');
  const count = countResult.length > 0 && countResult[0].values.length > 0 ? countResult[0].values[0][0] : 0;
  if (!count) {
    const stmt = db.prepare(`INSERT INTO books (id,title,author,genre,description,cover_url,price,stock,rating,review_count,bestseller,new_arrival,featured) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`);
    initialBooks.forEach(row => {
      stmt.bind(row);
      stmt.step();
      stmt.reset();
    });
    stmt.free();
  }

  // Save to file
  if (file !== ':memory:') {
    const data = db.export();
    fs.writeFileSync(file, Buffer.from(data));
  }
};

// Compatibility layer to mimic better-sqlite3 API
const dbCompat = {
  prepare: (sql) => {
    const stmt = db.prepare(sql);
    return {
      run: (...args) => {
        stmt.bind(args);
        stmt.step();
        stmt.reset();
        // Auto-save after writes
        if (file !== ':memory:') {
          const data = db.export();
          fs.writeFileSync(file, Buffer.from(data));
        }
        return { changes: db.getRowsModified() };
      },
      get: (...args) => {
        stmt.bind(args);
        const result = stmt.step() ? stmt.getAsObject() : undefined;
        stmt.reset();
        return result;
      },
      all: (...args) => {
        stmt.bind(args);
        const results = [];
        while (stmt.step()) {
          results.push(stmt.getAsObject());
        }
        stmt.reset();
        return results;
      },
      free: () => stmt.free()
    };
  },
  exec: (sql) => {
    db.exec(sql);
    if (file !== ':memory:') {
      const data = db.export();
      fs.writeFileSync(file, Buffer.from(data));
    }
  },
  pragma: (setting) => {
    db.run(`PRAGMA ${setting}`);
  },
  transaction: (fn) => {
    return (...args) => {
      db.run('BEGIN TRANSACTION');
      try {
        const result = fn(...args);
        db.run('COMMIT');
        if (file !== ':memory:') {
          const data = db.export();
          fs.writeFileSync(file, Buffer.from(data));
        }
        return result;
      } catch (e) {
        db.run('ROLLBACK');
        throw e;
      }
    };
  }
};

// Initialize and export
initDb().then(() => {
  module.exports = dbCompat;
}).catch(err => {
  console.error('Failed to initialize database:', err);
  process.exit(1);
});

// Export a promise that resolves when db is ready
module.exports = new Promise((resolve) => {
  initDb().then(() => resolve(dbCompat));
});
