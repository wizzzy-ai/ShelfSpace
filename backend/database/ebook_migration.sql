USE shelfspace;

ALTER TABLE Books
  ADD COLUMN ebookStorageKey VARCHAR(255) NULL AFTER soldCount,
  ADD COLUMN ebookFileName VARCHAR(255) NULL AFTER ebookStorageKey,
  ADD COLUMN ebookFormat ENUM('PDF','EPUB') NULL AFTER ebookFileName;
