# ShelfSpace REST API

Express API for the ShelfSpace Flutter bookstore. It persists users, books, carts, wishlists, reviews, and orders in MySQL. The API uses bearer tokens and role checks for protected operations.

## Run locally

Requires Node.js 20 or newer and MySQL. From this directory:

```sh
npm install
```

Create `backend/.env` with `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME` for your MySQL server. Also set `JWT_SECRET` to a unique random value of at least 32 characters, and set `ADMIN_EMAIL` and `ADMIN_PASSWORD` to credentials you choose (the password must be at least 12 characters). Never use example credentials in a deployed environment.

To set up a fresh catalog in MySQL Workbench, run `database/shelfspace.sql`, `database/app_migration.sql`, and `database/ebook_migration.sql`. To populate a fresh catalog, run `database/seed.sql` afterward. **The seed script truncates and replaces the existing books, authors, genres, and book-to-genre links**, so back up those tables or confirm they can be replaced before running it. For an existing database, run any migrations not already applied. From the `backend` directory, start the API with:

```sh
npm run seed:admin
npm run dev
```

The seed command creates an admin account using the configured name, email, and password. Sign in to ShelfSpace with that email and password; only accounts with the admin role see the Admin Panel. Normal sign-up always creates a customer account. The seed command never changes an existing admin password and reports an error if the configured email already belongs to a customer. The API also seeds the admin automatically at startup when both admin environment variables are configured.

The service listens on `http://localhost:3000`. It connects to the MySQL database configured in `backend/.env`; `backend/data/shelfspace.sqlite` is not used by the current API.

For Android emulator use `http://10.0.2.2:3000`; iOS simulator and desktop can use `http://localhost:3000`. For a physical device, use the development machine's LAN address. Set `CLIENT_ORIGIN` to a comma-separated list of trusted browser origins in production.

## API

JSON errors have the shape `{ "error": "..." }`. Authenticated routes use `Authorization: Bearer <token>`. Registration/login return `{ user, token }`; tokens expire in seven days. Book JSON uses the Flutter model's `coverUrl`, `reviewCount`, `isBestseller`, `isNewArrival`, and `isFeatured` property names.

| Method | Path | Access | Purpose |
|---|---|---|---|
| GET | `/api/health` | Public | Health check |
| POST | `/api/auth/register` | Public | Create customer account (`name`, `email`, `password`, optional `phone`) |
| POST | `/api/auth/login` | Public | Sign in (`email`, `password`) |
| GET/PATCH | `/api/auth/me` | Customer | Read/update profile (`name`, `phone`) |
| POST | `/api/auth/change-password` | Customer | Change password |
| POST | `/api/auth/forgot-password` | Public | Create one-time reset token; development returns token for local use |
| POST | `/api/auth/reset-password` | Public | Reset with `{ token, newPassword }` |
| GET | `/api/books` | Public | Catalog; supports `q`, `genre`, `featured`, `bestseller`, `newArrival`, `sort`, `page`, `limit` |
| GET | `/api/books/:id` | Public | Book details |
| GET | `/api/books/:id/reviews` | Public | Reviews for a book |
| POST | `/api/books/:id/reviews` | Customer | Add one review per customer (`rating` 1–5, `comment`) |
| GET/POST | `/api/cart` and `/api/cart/items` | Customer | Read cart, add `{ bookId, quantity? }` |
| PATCH/DELETE | `/api/cart/items/:bookId` | Customer | Set quantity (zero removes) or remove item |
| DELETE | `/api/cart` | Customer | Empty cart |
| GET | `/api/wishlist` | Customer | Read wishlist |
| POST/DELETE | `/api/wishlist/:bookId` | Customer | Add/remove a book |
| POST | `/api/orders` | Customer | Checkout from server-side cart and current prices/stock |
| GET | `/api/orders` | Customer | List own orders |
| GET | `/api/orders/:id` | Customer | Read own order |
| GET | `/api/library` | Customer | List ebooks from paid, non-cancelled orders |
| GET | `/api/library/:bookId/file` | Customer | Download a purchased ebook after payment confirmation |
| GET | `/api/admin/summary` | Admin | Dashboard counts and revenue |
| POST/PATCH/DELETE | `/api/admin/books[/:id]` | Admin | Manage catalog |
| PUT | `/api/admin/books/:id/ebook` | Admin | Upload or replace a PDF/EPUB (`application/octet-stream`, filename in `X-Ebook-Filename`, max 50 MB) |
| GET | `/api/admin/orders` | Admin | List orders (optional `status`) |
| PATCH | `/api/admin/orders/:id/status` | Admin | Set `Processing`, `Confirmed`, `Shipped`, `Delivered`, or `Cancelled` |
| PATCH | `/api/admin/orders/:id/payment` | Admin | Confirm receipt of payment and unlock included ebooks |
| GET | `/api/admin/users` | Admin | Search customers (`q`) |
| PATCH/DELETE | `/api/admin/users/:id/status` or `/api/admin/users/:id` | Admin | Disable/enable or delete a customer |

Book create/update fields are `title`, `author`, `genre`, `description`, `coverUrl`, `price`, `stock`, `isBestseller`, `isNewArrival`, and `isFeatured`. Prices are NGN amounts, consistent with the current app. Checkout uses the app's current flat ₦1,500 delivery fee, rechecks book stock and prices inside a database transaction, deducts stock, records order line snapshots, and clears the cart.

Admins upload an ebook from Book Management. In Order Management, the admin confirms payment after receiving it; included ebooks with an uploaded PDF or EPUB then become available under Profile → My Library and on that purchased book's details page, unless the order is cancelled. The details page checks access again while open, so the Read in app and Download actions appear after payment confirmation. Changing the order's fulfillment status is separate from confirming payment. The library can read PDFs and EPUBs in the app and saves a copy in the app's local documents for offline reading; Download also opens the device's save/download flow. Ebook files are stored privately under `backend/storage/ebooks` by default (or `EBOOK_STORAGE_DIR` if configured), not exposed as public static files. Back up this directory with the database.

## Production notes

- Configure HTTPS, a strong secret, a restricted `CLIENT_ORIGIN`, and persistent MySQL storage. Back up the database regularly.
- Password reset responses intentionally avoid revealing whether an email exists. In development only, the reset token is returned in the response. In production, connect the reset-token creation to a real email provider before enabling password recovery.
- Checkout records the chosen payment method and order; it does not charge a card or verify a mobile-money transfer. The admin's payment confirmation is a manual acknowledgement, not provider verification. Connect a payment provider and verify signed provider webhooks before automating paid status.
- The Flutter app reads the book catalog from this API. Ensure the API is connected to the intended MySQL database and that it contains books.
