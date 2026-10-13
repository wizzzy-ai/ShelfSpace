require('dotenv').config();
const db = require('./src/db');

async function clearUsers() {
  try {
    console.log('Clearing all users and related data...\n');

    // Show current users
    const [users] = await db.query("SELECT id, name, email, role FROM Users WHERE role = 'USER'");
    console.log('Users before clearing:');
    console.log('ID | Name | Email | Role');
    console.log('---|------|-------|-----');
    for (const user of users) {
      console.log(`${user.id} | ${user.name} | ${user.email} | ${user.role}`);
    }

    if (users.length === 0) {
      console.log('\nNo users found.');
      process.exit(0);
    }

    console.log(`\nFound ${users.length} user(s).\n`);

    // Delete in order to respect foreign key constraints
    console.log('Deleting related data...');

    // Delete payments (linked to orders)
    const [payments] = await db.query('DELETE FROM Payments');
    console.log(`✓ Deleted ${payments.affectedRows} payment(s)`);

    // Delete order items
    const [orderItems] = await db.query('DELETE FROM OrderItems');
    console.log(`✓ Deleted ${orderItems.affectedRows} order item(s)`);

    // Delete orders
    const [orders] = await db.query('DELETE FROM Orders');
    console.log(`✓ Deleted ${orders.affectedRows} order(s)`);

    // Delete reviews
    const [reviews] = await db.query('DELETE FROM Reviews');
    console.log(`✓ Deleted ${reviews.affectedRows} review(s)`);

    // Delete wishlist items
    const [wishlist] = await db.query('DELETE FROM WishlistItems');
    console.log(`✓ Deleted ${wishlist.affectedRows} wishlist item(s)`);

    // Delete cart items
    const [cart] = await db.query('DELETE FROM CartItems');
    console.log(`✓ Deleted ${cart.affectedRows} cart item(s)`);

    // Delete users (except admin)
    const [result] = await db.query("DELETE FROM Users WHERE role = 'USER'");
    console.log(`✓ Deleted ${result.affectedRows} user(s)\n`);

    // Verify
    const [remaining] = await db.query("SELECT COUNT(*) as count FROM Users WHERE role = 'USER'");
    console.log(`✓ Users remaining: ${remaining[0].count}\n`);

    console.log('✓ All users and their data have been cleared.');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

clearUsers();
