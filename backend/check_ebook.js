require('dotenv').config();
const db = require('./src/db');
const fs = require('node:fs/promises');
const path = require('node:path');

async function checkEbook() {
  try {
    console.log('Checking ebook files...\n');

    // Check Books table for ebook info
    const [books] = await db.query(`
      SELECT id, title, ebookStorageKey, ebookFileName, ebookFormat
      FROM Books
      WHERE ebookStorageKey IS NOT NULL
      ORDER BY title
    `);

    console.log('Books with uploaded ebook files:');
    console.log('ID | Title | Storage Key | File Name | Format');
    console.log('---|-------|-------------|-----------|--------');
    for (const book of books) {
      console.log(`${book.id} | ${book.title} | ${book.ebookStorageKey} | ${book.ebookFileName} | ${book.ebookFormat}`);
    }

    if (books.length === 0) {
      console.log('\nNo books with uploaded ebook files found.');
    } else {
      console.log(`\nFound ${books.length} book(s) with ebook files.\n`);

      // Check if files actually exist in storage
      const EBOOK_DIRECTORY = path.resolve(process.env.EBOOK_STORAGE_DIR || path.join(__dirname, '../storage/ebooks'));
      console.log(`Checking storage directory: ${EBOOK_DIRECTORY}\n`);

      for (const book of books) {
        const filePath = path.join(EBOOK_DIRECTORY, path.basename(book.ebookStorageKey));
        try {
          await fs.access(filePath);
          const stats = await fs.stat(filePath);
          console.log(`✓ ${book.title}: File exists (${(stats.size / 1024).toFixed(2)} KB)`);
        } catch (error) {
          console.log(`✗ ${book.title}: File NOT found (${error.code})`);
        }
      }
    }

    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

checkEbook();
