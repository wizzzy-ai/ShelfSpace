require('dotenv').config();
const db = require('./src/db');

async function createTestOrder() {
  try {
    const userId = 1; // User ID
    const bookId = 29; // Becoming book ID

    console.log('Creating test order...\n');

    // Create order
    const [order] = await db.query(
      'INSERT INTO Orders (userId, totalAmount, shippingName, shippingPhone, shippingStreet, shippingCity, shippingState, shippingCountry) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [userId, 10000, 'Test User', '1234567890', '123 Test St', 'Test City', 'Test State', 'Nigeria']
    );
    console.log(`✓ Created order ${order.insertId}`);

    // Add order item
    const [book] = await db.query('SELECT title, price FROM Books WHERE id = ?', [bookId]);
    await db.query(
      'INSERT INTO OrderItems (orderId, bookId, title, quantity, price) VALUES (?, ?, ?, ?, ?)',
      [order.insertId, bookId, book[0].title, 1, book[0].price]
    );
    console.log(`✓ Added book "${book[0].title}" to order`);

    // Create payment with SUCCESS status
    await db.query(
      'INSERT INTO Payments (orderId, amount, method, status, paidAt) VALUES (?, ?, ?, ?, NOW())',
      [order.insertId, 10000, 'CARD', 'SUCCESS']
    );
    console.log(`✓ Payment confirmed (SUCCESS status)`);

    // Update order status
    await db.query("UPDATE Orders SET status = 'PROCESSING' WHERE id = ?", [order.insertId]);
    console.log(`✓ Order status set to PROCESSING`);

    console.log('\n✓ Test order created successfully!');
    console.log(`User ${userId} can now access book ${bookId} (Becoming)`);
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

createTestOrder();
