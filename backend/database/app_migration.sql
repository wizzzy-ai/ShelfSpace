USE shelfspace;

ALTER TABLE Users
  ADD COLUMN phone VARCHAR(30) NOT NULL DEFAULT '' AFTER email,
  ADD COLUMN disabled BOOLEAN NOT NULL DEFAULT FALSE AFTER isVerified;

ALTER TABLE Books
  ADD COLUMN isBestseller BOOLEAN NOT NULL DEFAULT FALSE AFTER soldCount,
  ADD COLUMN isNewArrival BOOLEAN NOT NULL DEFAULT FALSE AFTER isBestseller,
  ADD COLUMN isFeatured BOOLEAN NOT NULL DEFAULT FALSE AFTER isNewArrival;

UPDATE Books
SET isBestseller = (soldCount >= 150),
    isFeatured   = (soldCount >= 200),
    isNewArrival = (COALESCE(releaseDate, DATE(createdAt)) >= DATE_SUB(CURDATE(), INTERVAL 90 DAY))
WHERE id > 0;