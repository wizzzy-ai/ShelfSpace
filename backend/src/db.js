require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'shelfspace',
  waitForConnections: true,
  connectionLimit: 10,
  decimalNumbers: true
});

const REQUIRED_COLUMNS = {
  Users: ['phone', 'disabled'],
  Books: ['isBestseller', 'isNewArrival', 'isFeatured']
};

pool.checkSchema = async function checkSchema() {
  try {
    await pool.query('SELECT 1');
  } catch (error) {
    throw new Error(`Cannot connect to MySQL (${error.code || error.message}). Check DB_HOST, DB_USER, DB_PASSWORD and DB_NAME in .env, and that MySQL is running.`);
  }
  const missing = [];
  for (const [table, columns] of Object.entries(REQUIRED_COLUMNS)) {
    const [rows] = await pool.query(
      'SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND LOWER(TABLE_NAME) = LOWER(?)',
      [table]
    );
    if (rows.length === 0) throw new Error(`Table ${table} was not found. Run database/shelfspace.sql in MySQL Workbench first.`);
    const have = rows.map(row => row.COLUMN_NAME);
    for (const column of columns) if (!have.includes(column)) missing.push(`${table}.${column}`);
  }
  if (missing.length) {
    throw new Error(`Your database is missing: ${missing.join(', ')}. Run backend/database/app_migration.sql in MySQL Workbench once, then restart.`);
  }
};

module.exports = pool;