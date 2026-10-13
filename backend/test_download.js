require('dotenv').config();
const db = require('./src/db');
const jwt = require('jsonwebtoken');

async function testDownload() {
  try {
    console.log('Testing ebook download endpoint...\n');

    // Get test user
    const [users] = await db.query("SELECT * FROM Users WHERE email = 'test@example.com'");
    if (!users[0]) {
      console.log('Test user not found');
      process.exit(1);
    }

    const user = users[0];
    console.log(`Found user: ${user.name} (ID: ${user.id})`);

    // Generate token
    const token = jwt.sign(
      { sub: String(user.id), role: 'customer' },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    console.log(`Generated token: ${token.substring(0, 20)}...\n`);

    // Test the query that the endpoint uses
    const bookId = 29;
    const [rows] = await db.query(
      `SELECT b.ebookStorageKey, b.ebookFileName, b.ebookFormat
       FROM Orders o
       JOIN OrderItems oi ON oi.orderId = o.id
       JOIN Books b ON b.id = oi.bookId
       WHERE o.userId = ? AND o.status <> 'CANCELLED'
         AND EXISTS (SELECT 1 FROM Payments p WHERE p.orderId = o.id AND p.status = 'SUCCESS')
         AND b.id = ? AND b.ebookStorageKey IS NOT NULL
       LIMIT 1`,
      [user.id, bookId]
    );

    if (!rows[0]) {
      console.log('❌ No ebook found - user does not have access');
      process.exit(1);
    }

    console.log('✓ User has access to ebook:');
    console.log(`  Storage Key: ${rows[0].ebookStorageKey}`);
    console.log(`  File Name: ${rows[0].ebookFileName}`);
    console.log(`  Format: ${rows[0].ebookFormat}\n`);

    // Check if file exists
    const path = require('node:path');
    const fs = require('node:fs/promises');
    const EBOOK_DIRECTORY = path.resolve(process.env.EBOOK_STORAGE_DIR || path.join(__dirname, '../storage/ebooks'));
    const filePath = path.join(EBOOK_DIRECTORY, path.basename(rows[0].ebookStorageKey));

    try {
      await fs.access(filePath);
      const stats = await fs.stat(filePath);
      console.log(`✓ File exists: ${filePath}`);
      console.log(`  Size: ${(stats.size / 1024).toFixed(2)} KB\n`);
    } catch (error) {
      console.log(`❌ File not found: ${filePath}`);
      console.log(`  Error: ${error.code}\n`);
      process.exit(1);
    }

    console.log('✓ Everything looks good! The endpoint should work.');
    console.log('\nYou can test with curl:');
    console.log(`curl -H "Authorization: Bearer ${token}" http://localhost:3000/api/library/29/file`);

    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

testDownload();
