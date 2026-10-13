require('dotenv').config();
const db = require('./src/db');
const bcrypt = require('bcryptjs');

async function createTestUser() {
  try {
    console.log('Creating test user...\n');

    // Create user
    const passwordHash = await bcrypt.hash('password123', 12);
    const [user] = await db.query(
      'INSERT INTO Users (name, email, passwordHash, phone, isVerified) VALUES (?, ?, ?, ?, TRUE)',
      ['Test User', 'test@example.com', passwordHash, '1234567890']
    );
    console.log(`✓ Created user ${user.insertId} (test@example.com / password123)`);

    const userId = user.insertId;
    const bookId = 29; // Becoming

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

    console.log('\n✓ Test user created successfully!');
    console.log('\nLogin credentials:');
    console.log('Email: test@example.com');
    console.log('Password: password123');
    console.log('\nThis user has access to book 29 (Becoming) with a confirmed payment.');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

createTestUser();
