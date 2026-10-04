USE shelfspace;

-- Two test users
INSERT INTO Users (name, email, passwordHash, isVerified)
VALUES ('Test One', 'trigger.test1@example.com', 'x', TRUE);
SET @u1 = LAST_INSERT_ID();

INSERT INTO Users (name, email, passwordHash, isVerified)
VALUES ('Test Two', 'trigger.test2@example.com', 'x', TRUE);
SET @u2 = LAST_INSERT_ID();

SET @book = (SELECT id FROM Books WHERE title = 'Atomic Habits');

-- TEST 1: reviews. Before: 0.00 and 0
SELECT 'before reviews' AS step, ratingAvg, ratingCount FROM Books WHERE id = @book;

INSERT INTO Reviews (userId, bookId, rating, comment) VALUES
(@u1, @book, 5, 'Great book'),
(@u2, @book, 3, 'It was okay');

-- After: 4.00 and 2
SELECT 'after reviews' AS step, ratingAvg, ratingCount FROM Books WHERE id = @book;

-- TEST 2: placing an order. Before: stock 55, sold 240
SELECT 'before order' AS step, stockQuantity, soldCount FROM Books WHERE id = @book;

INSERT INTO Orders (userId, totalAmount, shippingName, shippingStreet, shippingCity, shippingState, shippingCountry)
VALUES (@u1, 15000.00, 'Test One', '1 Test Street', 'Lagos', 'Lagos', 'Nigeria');
SET @order = LAST_INSERT_ID();

INSERT INTO OrderItems (orderId, bookId, title, quantity, price)
VALUES (@order, @book, 'Atomic Habits', 2, 7500.00);

-- After: stock 53, sold 242
SELECT 'after order' AS step, stockQuantity, soldCount FROM Books WHERE id = @book;

-- TEST 3: payment. Order status should become PAID
INSERT INTO Payments (orderId, amount, method, status)
VALUES (@order, 15000.00, 'CARD', 'SUCCESS');

SELECT 'after payment' AS step, status FROM Orders WHERE id = @order;

-- TEST 4: cancel. Stock back to 55, sold back to 240
UPDATE Orders SET status = 'CANCELLED' WHERE id = @order;

SELECT 'after cancel' AS step, stockQuantity, soldCount FROM Books WHERE id = @book;

-- Tracking history: PENDING, PAID, CANCELLED
SELECT status, note, createdAt FROM OrderTracking WHERE orderId = @order ORDER BY id;

-- CLEAN UP (reviews are deleted first on purpose, so the rating goes back to 0)
DELETE FROM Reviews WHERE userId IN (@u1, @u2);
DELETE FROM Payments WHERE orderId = @order;
DELETE FROM Orders WHERE userId IN (@u1, @u2);
DELETE FROM Users WHERE email LIKE 'trigger.test%@example.com';

SELECT 'after cleanup' AS step, ratingAvg, ratingCount, stockQuantity, soldCount FROM Books WHERE id = @book;



USE shelfspace;
DELETE FROM Orders WHERE userId IN (SELECT id FROM Users WHERE email = 'trigger.test3@example.com');
DELETE FROM Users WHERE email = 'trigger.test3@example.com';