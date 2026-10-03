USE shelfspace;

DROP TRIGGER IF EXISTS trg_reviews_ai;
DROP TRIGGER IF EXISTS trg_reviews_au;
DROP TRIGGER IF EXISTS trg_reviews_ad;
DROP TRIGGER IF EXISTS trg_orderitems_bi;
DROP TRIGGER IF EXISTS trg_orderitems_ai;
DROP TRIGGER IF EXISTS trg_orders_ai;
DROP TRIGGER IF EXISTS trg_orders_au;
DROP TRIGGER IF EXISTS trg_payments_ai;
DROP TRIGGER IF EXISTS trg_payments_au;

DELIMITER $$

-- REVIEWS: keep each book's ratingAvg and ratingCount up to date
CREATE TRIGGER trg_reviews_ai AFTER INSERT ON Reviews
FOR EACH ROW
BEGIN
  UPDATE Books
  SET ratingAvg = COALESCE((SELECT ROUND(AVG(rating), 2) FROM Reviews WHERE bookId = NEW.bookId), 0),
      ratingCount = (SELECT COUNT(*) FROM Reviews WHERE bookId = NEW.bookId)
  WHERE id = NEW.bookId;
END$$

CREATE TRIGGER trg_reviews_au AFTER UPDATE ON Reviews
FOR EACH ROW
BEGIN
  UPDATE Books
  SET ratingAvg = COALESCE((SELECT ROUND(AVG(rating), 2) FROM Reviews WHERE bookId = NEW.bookId), 0),
      ratingCount = (SELECT COUNT(*) FROM Reviews WHERE bookId = NEW.bookId)
  WHERE id = NEW.bookId;
END$$

CREATE TRIGGER trg_reviews_ad AFTER DELETE ON Reviews
FOR EACH ROW
BEGIN
  UPDATE Books
  SET ratingAvg = COALESCE((SELECT ROUND(AVG(rating), 2) FROM Reviews WHERE bookId = OLD.bookId), 0),
      ratingCount = (SELECT COUNT(*) FROM Reviews WHERE bookId = OLD.bookId)
  WHERE id = OLD.bookId;
END$$

-- ORDER ITEMS: stop overselling, then lower stock and raise soldCount
CREATE TRIGGER trg_orderitems_bi BEFORE INSERT ON OrderItems
FOR EACH ROW
BEGIN
  DECLARE available INT;
  IF NEW.bookId IS NOT NULL THEN
    SELECT stockQuantity INTO available FROM Books WHERE id = NEW.bookId FOR UPDATE;
    IF available IS NULL OR available < NEW.quantity THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock for this book';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_orderitems_ai AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
  IF NEW.bookId IS NOT NULL THEN
    UPDATE Books
    SET stockQuantity = stockQuantity - NEW.quantity,
        soldCount = soldCount + NEW.quantity
    WHERE id = NEW.bookId;
  END IF;
END$$

-- ORDERS: write the tracking history, and put stock back if an order is cancelled
CREATE TRIGGER trg_orders_ai AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
  INSERT INTO OrderTracking (orderId, status, note)
  VALUES (NEW.id, NEW.status, 'Order placed');
END$$

CREATE TRIGGER trg_orders_au AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
  IF NEW.status <> OLD.status THEN
    INSERT INTO OrderTracking (orderId, status)
    VALUES (NEW.id, NEW.status);

    IF NEW.status = 'CANCELLED' THEN
      UPDATE Books b
      JOIN (
        SELECT bookId, SUM(quantity) AS qty
        FROM OrderItems
        WHERE orderId = NEW.id AND bookId IS NOT NULL
        GROUP BY bookId
      ) x ON x.bookId = b.id
      SET b.stockQuantity = b.stockQuantity + x.qty,
          b.soldCount = GREATEST(b.soldCount - x.qty, 0);
    END IF;
  END IF;
END$$

-- PAYMENTS: a successful payment marks a pending order as PAID
CREATE TRIGGER trg_payments_ai AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
  IF NEW.status = 'SUCCESS' THEN
    UPDATE Orders SET status = 'PAID'
    WHERE id = NEW.orderId AND status = 'PENDING';
  END IF;
END$$

CREATE TRIGGER trg_payments_au AFTER UPDATE ON Payments
FOR EACH ROW
BEGIN
  IF NEW.status = 'SUCCESS' AND OLD.status <> 'SUCCESS' THEN
    UPDATE Orders SET status = 'PAID'
    WHERE id = NEW.orderId AND status = 'PENDING';
  END IF;
END$$

DELIMITER ;

SHOW TRIGGERS;