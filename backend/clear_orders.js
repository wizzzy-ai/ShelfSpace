require('dotenv').config();
const db = require('./src/db');

async function clearOrders() {
  try {
    console.log('Clearing all orders...\n');

    // Show current orders before deletion
    const [before] = await db.query(`
      SELECT o.id, o.userId, o.status, o.totalAmount, o.createdAt,
             p.status as paymentStatus
      FROM Orders o
      LEFT JOIN Payments p ON p.orderId = o.id
      ORDER BY o.createdAt DESC
    `);

    console.log('Orders before clearing:');
    console.log('ID | User ID | Status | Amount | Payment Status | Created At');
    console.log('---|---------|--------|--------|----------------|------------');
    for (const order of before) {
      console.log(`${order.id} | ${order.userId} | ${order.status} | ${order.totalAmount} | ${order.paymentStatus || 'N/A'} | ${order.createdAt}`);
    }

    if (before.length === 0) {
      console.log('\nNo orders found.');
      process.exit(0);
    }

    console.log(`\nFound ${before.length} order(s).\n`);

    // Delete payments first (due to foreign key constraint)
    const [paymentsResult] = await db.query('DELETE FROM Payments');
    console.log(`✓ Deleted ${paymentsResult.affectedRows} payment(s).`);

    // Delete order items
    const [itemsResult] = await db.query('DELETE FROM OrderItems');
    console.log(`✓ Deleted ${itemsResult.affectedRows} order item(s).`);

    // Delete orders
    const [result] = await db.query('DELETE FROM Orders');
    console.log(`✓ Deleted ${result.affectedRows} order(s).\n`);

    // Verify deletion
    const [after] = await db.query('SELECT COUNT(*) as count FROM Orders');
    console.log(`✓ Orders remaining in database: ${after[0].count}\n`);

    console.log('✓ All orders have been cleared.');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

clearOrders();
