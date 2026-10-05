require('dotenv').config();
const { randomUUID } = require('node:crypto');
const bcrypt = require('bcryptjs');

async function seedAdmin(db, { required = false } = {}) {
  const email = (process.env.ADMIN_EMAIL || '').trim().toLowerCase();
  const password = process.env.ADMIN_PASSWORD;

  if (!email || !password) {
    if (!required) return null;
    throw new Error('Set ADMIN_EMAIL and ADMIN_PASSWORD before seeding an admin.');
  }
  if (password.length < 12) {
    throw new Error('ADMIN_PASSWORD must be at least 12 characters.');
  }

  const existing = db.prepare('SELECT id, role FROM users WHERE email=?').get(email);
  if (existing) {
    if (existing.role !== 'admin') {
      throw new Error(
        'ADMIN_EMAIL belongs to a customer account. Choose an email not already registered.',
      );
    }
    return { created: false, email };
  }

  const id = randomUUID();
  const passwordHash = await bcrypt.hash(password, 12);
  db.prepare(
    "INSERT INTO users(id,name,email,password_hash,role) VALUES(?,?,?,?,'admin')",
  ).run(id, process.env.ADMIN_NAME?.trim() || 'ShelfSpace Admin', email, passwordHash);

  return { created: true, email };
}

if (require.main === module) {
  const dbPromise = require('./db');
  dbPromise
    .then(db => seedAdmin(db, { required: true }))
    .then(result => {
      console.log(
        result.created
          ? `Created admin account for ${result.email}. Sign in with the configured credentials.`
          : `Admin account ${result.email} already exists; its password was not changed.`,
      );
    })
    .catch(error => {
      console.error(error.message);
      process.exitCode = 1;
    });
}

module.exports = { seedAdmin };
