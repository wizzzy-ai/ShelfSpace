require('dotenv').config();
const db = require('./src/db');

async function checkLibrary() {
  try {
    console.log('Checking Orders and Payments...\n');

    // Check all orders with their payment status
    const [orders] = await db.query(`
      SELECT o.id, o.userId, o.status, o.totalAmount, o.createdAt,
             p.id as paymentId, p.status as paymentStatus, p.method, p.paidAt
      FROM Orders o
      LEFT JOIN Payments p ON p.orderId = o.id
      ORDER BY o.createdAt DESC
      LIMIT 10
    `);

    console.log('Recent Orders:');
    console.log('ID | User ID | Order Status | Payment Status | Amount | Created At');
    console.log('---|---------|--------------|----------------|--------|------------');
    for (const order of orders) {
      console.log(`${order.id} | ${order.userId} | ${order.status} | ${order.paymentStatus || 'N/A'} | ${order.totalAmount} | ${order.createdAt}`);
    }

    console.log('\n\nChecking Library Query for User 1...\n');

    // Simulate the library query for a specific user (change userId as needed)
    const userId = 1; // Change this to the actual user ID
    const [library] = await db.query(`
      SELECT DISTINCT b.id, b.title, a.name AS author, b.imageUrl, b.ebookFormat, b.ebookFileName, b.ebookStorageKey
      FROM Orders o
      JOIN OrderItems oi ON oi.orderId = o.id
      JOIN Books b ON b.id = oi.bookId
      JOIN Authors a ON a.id = b.authorId
      WHERE o.userId = ? AND o.status <> 'CANCELLED'
        AND EXISTS (SELECT 1 FROM Payments p WHERE p.orderId = o.id AND p.status = 'SUCCESS')
      ORDER BY b.title
    `, [userId]);

    console.log(`Library for User ${userId}:`);
    if (library.length === 0) {
      console.log('No books found in library');
    } else {
      console.log('ID | Title | Author | Has File');
      console.log('---|-------|--------|---------');
      for (const book of library) {
        console.log(`${book.id} | ${book.title} | ${book.author} | ${book.ebookStorageKey ? 'Yes' : 'No'}`);
      }
    }

    // Check for user 5 as well
    const userId2 = 5;
    const [library2] = await db.query(`
      SELECT DISTINCT b.id, b.title, a.name AS author, b.imageUrl, b.ebookFormat, b.ebookFileName, b.ebookStorageKey
      FROM Orders o
      JOIN OrderItems oi ON oi.orderId = o.id
      JOIN Books b ON b.id = oi.bookId
      JOIN Authors a ON a.id = b.authorId
      WHERE o.userId = ? AND o.status <> 'CANCELLED'
        AND EXISTS (SELECT 1 FROM Payments p WHERE p.orderId = o.id AND p.status = 'SUCCESS')
      ORDER BY b.title
    `, [userId2]);

    console.log(`\n\nLibrary for User ${userId2}:`);
    if (library2.length === 0) {
      console.log('No books found in library');
    } else {
      console.log('ID | Title | Author | Has File');
      console.log('---|-------|--------|---------');
      for (const book of library2) {
        console.log(`${book.id} | ${book.title} | ${book.author} | ${book.ebookStorageKey ? 'Yes' : 'No'}`);
      }
    }

    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

checkLibrary();
