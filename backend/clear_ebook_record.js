require('dotenv').config();
const db = require('./src/db');

async function clearEbookRecord() {
  try {
    console.log('Clearing ebook records for missing files...\n');

    // Find books with ebookStorageKey but no actual file
    const EBOOK_DIRECTORY = require('path').resolve(process.env.EBOOK_STORAGE_DIR || require('path').join(__dirname, '../storage/ebooks'));
    const fs = require('node:fs/promises');

    const [books] = await db.query(`
      SELECT id, title, ebookStorageKey, ebookFileName, ebookFormat
      FROM Books
      WHERE ebookStorageKey IS NOT NULL
    `);

    console.log('Checking books with ebook records...');
    let cleared = 0;

    for (const book of books) {
      const filePath = require('path').join(EBOOK_DIRECTORY, require('path').basename(book.ebookStorageKey));
      try {
        await fs.access(filePath);
        console.log(`✓ ${book.title}: File exists, keeping record`);
      } catch (error) {
        console.log(`✗ ${book.title}: File missing, clearing record`);
        await db.query(
          'UPDATE Books SET ebookStorageKey = NULL, ebookFileName = NULL, ebookFormat = NULL WHERE id = ?',
          [book.id]
        );
        cleared++;
      }
    }

    console.log(`\n✓ Cleared ${cleared} ebook record(s) for missing files.`);
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

clearEbookRecord();
