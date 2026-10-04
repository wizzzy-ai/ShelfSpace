USE shelfspace;


SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE BookGenres;
TRUNCATE TABLE Books;
TRUNCATE TABLE Genres;
TRUNCATE TABLE Authors;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. AUTHORS
INSERT INTO Authors (name, description) VALUES
('Chinua Achebe', 'Nigerian novelist and one of the most important African writers.'),
('Chimamanda Ngozi Adichie', 'Nigerian author of novels, short stories and essays.'),
('Tomi Adeyemi', 'Nigerian-American author of young adult fantasy.'),
('Ayobami Adebayo', 'Nigerian novelist and winner of several literary prizes.'),
('Chigozie Obioma', 'Nigerian novelist whose books explore family and fate.'),
('J.K. Rowling', 'British author of the Harry Potter series.'),
('J.R.R. Tolkien', 'English writer and creator of Middle-earth.'),
('Paulo Coelho', 'Brazilian novelist and author of The Alchemist.'),
('Harper Lee', 'American novelist known for To Kill a Mockingbird.'),
('George Orwell', 'English writer known for sharp stories about power and politics.'),
('Aldous Huxley', 'English writer and author of Brave New World.'),
('Jane Austen', 'English novelist known for stories of love and society.'),
('F. Scott Fitzgerald', 'American writer who captured the Jazz Age.'),
('J.D. Salinger', 'American writer best known for The Catcher in the Rye.'),
('Suzanne Collins', 'American author of The Hunger Games trilogy.'),
('Dan Brown', 'American author of fast-paced mystery thrillers.'),
('Gillian Flynn', 'American author of dark psychological thrillers.'),
('Stieg Larsson', 'Swedish journalist and author of the Millennium series.'),
('Khaled Hosseini', 'Afghan-American novelist and physician.'),
('Yann Martel', 'Canadian author of Life of Pi.'),
('Frank Herbert', 'American science fiction author who created the Dune universe.'),
('James Clear', 'American writer and speaker on habits and self-improvement.'),
('Robert Kiyosaki', 'American author and investor focused on personal finance.'),
('Morgan Housel', 'American writer on money, behavior and investing.'),
('Yuval Noah Harari', 'Israeli historian and author of books on human history.'),
('Michelle Obama', 'Lawyer, author and former First Lady of the United States.'),
('Tara Westover', 'American author and historian.');

-- 2. GENRES
INSERT INTO Genres (name, description) VALUES
('Fiction', 'Made-up stories and novels.'),
('Historical Fiction', 'Stories set in a real period of history.'),
('Classic', 'Books that have stayed popular for many years.'),
('Fantasy', 'Stories with magic and imaginary worlds.'),
('Adventure', 'Stories about journeys and quests.'),
('Science Fiction', 'Stories about science, technology and the future.'),
('Dystopian', 'Stories set in harsh, controlled societies.'),
('Romance', 'Stories about love and relationships.'),
('Mystery & Thriller', 'Suspenseful stories full of secrets and crimes.'),
('Young Adult', 'Books written mainly for teenage readers.'),
('Self-Help', 'Books on improving your life and habits.'),
('Business & Finance', 'Books on money, work and investing.'),
('Biography & Memoir', 'True life stories.'),
('History', 'Books about real events and the past.');

-- 3. BOOKS
INSERT INTO Books (title, authorId, description, imageUrl, price, releaseDate, stockQuantity, soldCount) VALUES
('Things Fall Apart', (SELECT id FROM Authors WHERE name = 'Chinua Achebe'),
 'Okonkwo is a respected leader in an Igbo village until colonial rule and a new religion shake his world.',
 'https://covers.openlibrary.org/b/isbn/9780385474542-L.jpg', 4500.00, '1958-01-01', 40, 180),
('Half of a Yellow Sun', (SELECT id FROM Authors WHERE name = 'Chimamanda Ngozi Adichie'),
 'The lives of three people are tangled together during the Nigerian civil war.',
 'https://covers.openlibrary.org/b/isbn/9781400095209-L.jpg', 5500.00, '2006-01-01', 30, 120),
('Americanah', (SELECT id FROM Authors WHERE name = 'Chimamanda Ngozi Adichie'),
 'A young Nigerian woman moves to America, builds a new life, and later returns to Lagos to face her past love.',
 'https://covers.openlibrary.org/b/isbn/9780307455925-L.jpg', 6000.00, '2013-01-01', 35, 150),
('Purple Hibiscus', (SELECT id FROM Authors WHERE name = 'Chimamanda Ngozi Adichie'),
 'Fifteen-year-old Kambili lives under her strict, religious father until a stay with her aunt shows her another way of living.',
 'https://covers.openlibrary.org/b/isbn/9781616202415-L.jpg', 5000.00, '2003-01-01', 28, 90),
('Children of Blood and Bone', (SELECT id FROM Authors WHERE name = 'Tomi Adeyemi'),
 'In a land where magic was wiped out, a young girl fights to bring it back and challenge a cruel king.',
 'https://covers.openlibrary.org/b/isbn/9781250170972-L.jpg', 7000.00, '2018-03-06', 25, 95),
('Stay With Me', (SELECT id FROM Authors WHERE name = 'Ayobami Adebayo'),
 'A Nigerian couple faces pressure to have a child, and a secret threatens their marriage.',
 'https://covers.openlibrary.org/b/isbn/9780451494658-L.jpg', 5500.00, '2017-08-22', 20, 60),
('The Fishermen', (SELECT id FROM Authors WHERE name = 'Chigozie Obioma'),
 'Four brothers in a Nigerian town meet a mad prophet whose prediction changes their family forever.',
 'https://covers.openlibrary.org/b/isbn/9780316338387-L.jpg', 5500.00, '2015-04-14', 22, 55),
('Harry Potter and the Philosopher''s Stone', (SELECT id FROM Authors WHERE name = 'J.K. Rowling'),
 'An orphan boy learns he is a wizard and begins his first year at Hogwarts School of Witchcraft and Wizardry.',
 'https://covers.openlibrary.org/b/isbn/9780747532743-L.jpg', 6500.00, '1997-06-26', 60, 250),
('The Hobbit', (SELECT id FROM Authors WHERE name = 'J.R.R. Tolkien'),
 'Bilbo Baggins leaves his quiet home to join dwarves on a journey to win back treasure from a dragon.',
 'https://covers.openlibrary.org/b/isbn/9780547928227-L.jpg', 6000.00, '1937-09-21', 40, 140),
('The Alchemist', (SELECT id FROM Authors WHERE name = 'Paulo Coelho'),
 'A shepherd boy travels from Spain to Egypt in search of treasure and learns to follow his dreams.',
 'https://covers.openlibrary.org/b/isbn/9780062315007-L.jpg', 4000.00, '1988-01-01', 50, 220),
('To Kill a Mockingbird', (SELECT id FROM Authors WHERE name = 'Harper Lee'),
 'In a small Southern town, a young girl watches her lawyer father defend a Black man falsely accused of a crime.',
 'https://covers.openlibrary.org/b/isbn/9780061120084-L.jpg', 4500.00, '1960-07-11', 35, 130),
('1984', (SELECT id FROM Authors WHERE name = 'George Orwell'),
 'In a country watched by Big Brother, one man risks everything to think and love freely.',
 'https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg', 3500.00, '1949-06-08', 45, 190),
('Animal Farm', (SELECT id FROM Authors WHERE name = 'George Orwell'),
 'Farm animals rise up against their owner, but their new leaders soon become as harsh as the old one.',
 'https://covers.openlibrary.org/b/isbn/9780451526342-L.jpg', 3000.00, '1945-08-17', 45, 160),
('Brave New World', (SELECT id FROM Authors WHERE name = 'Aldous Huxley'),
 'A future society keeps everyone happy through control and comfort, until one outsider questions it.',
 'https://covers.openlibrary.org/b/isbn/9780060850524-L.jpg', 4000.00, '1932-01-01', 30, 100),
('Pride and Prejudice', (SELECT id FROM Authors WHERE name = 'Jane Austen'),
 'Elizabeth Bennet and the proud Mr. Darcy must get past first impressions and class differences to find love.',
 'https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg', 3500.00, '1813-01-28', 40, 170),
('The Great Gatsby', (SELECT id FROM Authors WHERE name = 'F. Scott Fitzgerald'),
 'A mysterious millionaire throws lavish parties in the hope of winning back the woman he loved.',
 'https://covers.openlibrary.org/b/isbn/9780743273565-L.jpg', 3500.00, '1925-04-10', 38, 145),
('The Catcher in the Rye', (SELECT id FROM Authors WHERE name = 'J.D. Salinger'),
 'Teenager Holden Caulfield wanders New York after leaving school and struggles with growing up.',
 'https://covers.openlibrary.org/b/isbn/9780316769488-L.jpg', 4000.00, '1951-07-16', 25, 85),
('The Hunger Games', (SELECT id FROM Authors WHERE name = 'Suzanne Collins'),
 'Katniss volunteers to take part in a deadly televised contest in place of her younger sister.',
 'https://covers.openlibrary.org/b/isbn/9780439023528-L.jpg', 5000.00, '2008-09-14', 45, 200),
('The Da Vinci Code', (SELECT id FROM Authors WHERE name = 'Dan Brown'),
 'A symbologist and a codebreaker race to solve a murder and a puzzle hidden in famous art.',
 'https://covers.openlibrary.org/b/isbn/9780307474278-L.jpg', 5000.00, '2003-03-18', 30, 135),
('Gone Girl', (SELECT id FROM Authors WHERE name = 'Gillian Flynn'),
 'When his wife disappears on their anniversary, a husband becomes the main suspect.',
 'https://covers.openlibrary.org/b/isbn/9780307588371-L.jpg', 5000.00, '2012-06-05', 28, 110),
('The Girl with the Dragon Tattoo', (SELECT id FROM Authors WHERE name = 'Stieg Larsson'),
 'A journalist and a skilled hacker investigate a decades-old disappearance in a wealthy Swedish family.',
 'https://covers.openlibrary.org/b/isbn/9780307454546-L.jpg', 5500.00, '2005-08-01', 26, 105),
('The Kite Runner', (SELECT id FROM Authors WHERE name = 'Khaled Hosseini'),
 'A man looks back on his childhood friendship in Afghanistan and the betrayal he spends his life trying to make right.',
 'https://covers.openlibrary.org/b/isbn/9781594631931-L.jpg', 5000.00, '2003-05-29', 32, 125),
('Life of Pi', (SELECT id FROM Authors WHERE name = 'Yann Martel'),
 'A boy survives a shipwreck and spends months on a lifeboat with a Bengal tiger.',
 'https://covers.openlibrary.org/b/isbn/9780156027328-L.jpg', 4500.00, '2001-09-11', 24, 80),
('Dune', (SELECT id FROM Authors WHERE name = 'Frank Herbert'),
 'Young Paul Atreides is thrown into a struggle for control of a desert planet and its precious spice.',
 'https://covers.openlibrary.org/b/isbn/9780441172719-L.jpg', 6500.00, '1965-08-01', 30, 115),
('Atomic Habits', (SELECT id FROM Authors WHERE name = 'James Clear'),
 'A practical guide to building good habits and breaking bad ones through small, steady changes.',
 'https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg', 7500.00, '2018-10-16', 55, 240),
('Rich Dad Poor Dad', (SELECT id FROM Authors WHERE name = 'Robert Kiyosaki'),
 'The author compares two views on money and explains how to think about assets, income and investing.',
 'https://covers.openlibrary.org/b/isbn/9781612680194-L.jpg', 5000.00, '1997-04-01', 45, 210),
('The Psychology of Money', (SELECT id FROM Authors WHERE name = 'Morgan Housel'),
 'Short stories on how behavior, not just knowledge, shapes the way people save, spend and invest.',
 'https://covers.openlibrary.org/b/isbn/9780857197689-L.jpg', 6500.00, '2020-09-08', 40, 155),
('Sapiens', (SELECT id FROM Authors WHERE name = 'Yuval Noah Harari'),
 'A sweeping look at how humans went from hunter-gatherers to the dominant species on Earth.',
 'https://covers.openlibrary.org/b/isbn/9780062316097-L.jpg', 7500.00, '2014-02-10', 35, 165),
('Becoming', (SELECT id FROM Authors WHERE name = 'Michelle Obama'),
 'The former First Lady tells her life story, from a childhood in Chicago to the White House.',
 'https://covers.openlibrary.org/b/isbn/9781524763138-L.jpg', 8500.00, '2018-11-13', 30, 175),
('Educated', (SELECT id FROM Authors WHERE name = 'Tara Westover'),
 'A woman raised by survivalists in rural Idaho teaches herself enough to earn a university degree.',
 'https://covers.openlibrary.org/b/isbn/9780399590504-L.jpg', 7000.00, '2018-02-20', 28, 130);

-- 4. LINK BOOKS TO GENRES
INSERT INTO BookGenres (bookId, genreId)
SELECT b.id, g.id FROM Books b, Genres g
WHERE (b.title = 'Things Fall Apart' AND g.name IN ('Fiction', 'Historical Fiction', 'Classic'))
   OR (b.title = 'Half of a Yellow Sun' AND g.name IN ('Fiction', 'Historical Fiction'))
   OR (b.title = 'Americanah' AND g.name IN ('Fiction', 'Romance'))
   OR (b.title = 'Purple Hibiscus' AND g.name IN ('Fiction'))
   OR (b.title = 'Children of Blood and Bone' AND g.name IN ('Fantasy', 'Young Adult'))
   OR (b.title = 'Stay With Me' AND g.name IN ('Fiction', 'Romance'))
   OR (b.title = 'The Fishermen' AND g.name IN ('Fiction'))
   OR (b.title = 'Harry Potter and the Philosopher''s Stone' AND g.name IN ('Fantasy', 'Young Adult'))
   OR (b.title = 'The Hobbit' AND g.name IN ('Fantasy', 'Adventure', 'Classic'))
   OR (b.title = 'The Alchemist' AND g.name IN ('Fiction', 'Adventure'))
   OR (b.title = 'To Kill a Mockingbird' AND g.name IN ('Fiction', 'Classic', 'Historical Fiction'))
   OR (b.title = '1984' AND g.name IN ('Dystopian', 'Classic', 'Science Fiction'))
   OR (b.title = 'Animal Farm' AND g.name IN ('Dystopian', 'Classic'))
   OR (b.title = 'Brave New World' AND g.name IN ('Dystopian', 'Science Fiction', 'Classic'))
   OR (b.title = 'Pride and Prejudice' AND g.name IN ('Romance', 'Classic'))
   OR (b.title = 'The Great Gatsby' AND g.name IN ('Fiction', 'Classic'))
   OR (b.title = 'The Catcher in the Rye' AND g.name IN ('Fiction', 'Classic'))
   OR (b.title = 'The Hunger Games' AND g.name IN ('Dystopian', 'Young Adult', 'Adventure'))
   OR (b.title = 'The Da Vinci Code' AND g.name IN ('Mystery & Thriller'))
   OR (b.title = 'Gone Girl' AND g.name IN ('Mystery & Thriller'))
   OR (b.title = 'The Girl with the Dragon Tattoo' AND g.name IN ('Mystery & Thriller'))
   OR (b.title = 'The Kite Runner' AND g.name IN ('Fiction', 'Historical Fiction'))
   OR (b.title = 'Life of Pi' AND g.name IN ('Fiction', 'Adventure'))
   OR (b.title = 'Dune' AND g.name IN ('Science Fiction', 'Adventure'))
   OR (b.title = 'Atomic Habits' AND g.name IN ('Self-Help'))
   OR (b.title = 'Rich Dad Poor Dad' AND g.name IN ('Business & Finance', 'Self-Help'))
   OR (b.title = 'The Psychology of Money' AND g.name IN ('Business & Finance'))
   OR (b.title = 'Sapiens' AND g.name IN ('History'))
   OR (b.title = 'Becoming' AND g.name IN ('Biography & Memoir'))
   OR (b.title = 'Educated' AND g.name IN ('Biography & Memoir'));


SELECT COUNT(*) AS totalBooks FROM Books;

SELECT b.id, b.title, a.name AS author, b.price,
       GROUP_CONCAT(g.name SEPARATOR ', ') AS genres
FROM Books b
JOIN Authors a ON a.id = b.authorId
LEFT JOIN BookGenres bg ON bg.bookId = b.id
LEFT JOIN Genres g ON g.id = bg.genreId
GROUP BY b.id, b.title, a.name, b.price
ORDER BY b.id;


SELECT title, imageUrl FROM Books;


USE shelfspace;

UPDATE Books
SET imageUrl = 'https://covers.openlibrary.org/b/isbn/9780451494603-L.jpg'
WHERE title = 'Stay With Me';

UPDATE Books
SET imageUrl = 'https://covers.openlibrary.org/b/isbn/9780316338370-L.jpg'
WHERE title = 'The Fishermen';