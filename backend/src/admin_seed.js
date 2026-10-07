require('dotenv').config();
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

  const [rows] = await db.query('SELECT id, role FROM Users WHERE email = ?', [email]);
  if (rows.length) {
    if (rows[0].role !== 'ADMIN') {
      throw new Error('ADMIN_EMAIL belongs to a customer account. Choose an email not already registered.');
    }
    return { created: false, email };
  }

  const passwordHash = await bcrypt.hash(password, 12);
  await db.query(
    "INSERT INTO Users (name, email, passwordHash, role, isVerified) VALUES (?, ?, ?, 'ADMIN', TRUE)",
    [process.env.ADMIN_NAME?.trim() || 'ShelfSpace Admin', email, passwordHash]
  );
  return { created: true, email };
}

if (require.main === module) {
  const db = require('./db');
  db.checkSchema()
    .then(() => seedAdmin(db, { required: true }))
    .then(result => {
      console.log(
        result.created
          ? `Created admin account for ${result.email}. Sign in with the configured credentials.`
          : `Admin account ${result.email} already exists; its password was not changed.`
      );
    })
    .catch(error => {
      console.error(error.message);
      process.exitCode = 1;
    })
    .finally(() => db.end());
}

module.exports = { seedAdmin };