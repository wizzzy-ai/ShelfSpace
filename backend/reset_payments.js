require('dotenv').config();
const db = require('./src/db');

async function resetPayments() {
  try {
    console.log('Resetting payment statuses...\n');

    // Show current payment statuses
    const [before] = await db.query(`
      SELECT o.id as orderId, o.userId, o.status as orderStatus,
             p.id as paymentId, p.status as paymentStatus, p.paidAt
      FROM Orders o
      LEFT JOIN Payments p ON p.orderId = o.id
      WHERE p.status = 'SUCCESS'
      ORDER BY o.createdAt DESC
    `);

    console.log('Payments with SUCCESS status (before reset):');
    console.log('Order ID | User ID | Order Status | Payment ID | Payment Status | Paid At');
    console.log('----------|---------|--------------|------------|----------------|--------');
    for (const row of before) {
      console.log(`${row.orderId} | ${row.userId} | ${row.orderStatus} | ${row.paymentId} | ${row.paymentStatus} | ${row.paidAt || 'N/A'}`);
    }

    if (before.length === 0) {
      console.log('\nNo payments with SUCCESS status found.');
      process.exit(0);
    }

    console.log(`\nFound ${before.length} payment(s) with SUCCESS status.\n`);

    // Reset all SUCCESS payments to PENDING
    const [result] = await db.query(`
      UPDATE Payments
      SET status = 'PENDING', paidAt = NULL
      WHERE status = 'SUCCESS'
    `);

    console.log(`✓ Reset ${result.affectedRows} payment(s) to PENDING status.\n`);

    // Show after state
    const [after] = await db.query(`
      SELECT o.id as orderId, o.userId, o.status as orderStatus,
             p.id as paymentId, p.status as paymentStatus, p.paidAt
      FROM Orders o
      LEFT JOIN Payments p ON p.orderId = o.id
      ORDER BY o.createdAt DESC
      LIMIT 10
    `);

    console.log('Recent payments (after reset):');
    console.log('Order ID | User ID | Order Status | Payment ID | Payment Status | Paid At');
    console.log('----------|---------|--------------|------------|----------------|--------');
    for (const row of after) {
      console.log(`${row.orderId} | ${row.userId} | ${row.orderStatus} | ${row.paymentId} | ${row.paymentStatus} | ${row.paidAt || 'N/A'}`);
    }

    console.log('\n✓ All payments have been reset to PENDING status.');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

resetPayments();
