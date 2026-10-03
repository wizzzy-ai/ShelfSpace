# ShelfSpace REST API

Express API for the ShelfSpace Flutter bookstore. It persists users, books, carts, wishlists, reviews, and orders in SQLite. The API uses bearer tokens and role checks for protected operations.

## Run locally

Requires Node.js 20 or newer. From this directory:

```sh
npm install
```

Copy `.env.example` to `.env`, set `JWT_SECRET` to a unique random value of at least 32 characters, and set an admin email and password of at least 12 characters. Then run:

```sh
npm run dev
```

The service listens on `http://localhost:3000`. SQLite creates `data/shelfspace.sqlite` on first run and seeds the five books currently shown in the Flutter prototype. Set `DATABASE_FILE=:memory:` for an ephemeral database. The first admin account is created once when `ADMIN_EMAIL` and `ADMIN_PASSWORD` are configured; later password changes do not get overwritten on restart.

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
| GET | `/api/admin/summary` | Admin | Dashboard counts and revenue |
| POST/PATCH/DELETE | `/api/admin/books[/:id]` | Admin | Manage catalog |
| GET | `/api/admin/orders` | Admin | List orders (optional `status`) |
| PATCH | `/api/admin/orders/:id/status` | Admin | Set `Processing`, `Confirmed`, `Shipped`, `Delivered`, or `Cancelled` |
| GET | `/api/admin/users` | Admin | Search customers (`q`) |
| PATCH/DELETE | `/api/admin/users/:id/status` or `/api/admin/users/:id` | Admin | Disable/enable or delete a customer |

Book create/update fields are `title`, `author`, `genre`, `description`, `coverUrl`, `price`, `stock`, `isBestseller`, `isNewArrival`, and `isFeatured`. Prices are NGN amounts, consistent with the current app. Checkout uses the app's current flat ₦1,500 delivery fee, rechecks book stock and prices inside a database transaction, deducts stock, records order line snapshots, and clears the cart.

## Production notes

- Configure HTTPS, a strong secret, a restricted `CLIENT_ORIGIN`, and a persistent database volume. Back up the SQLite database.
- Password reset responses intentionally avoid revealing whether an email exists. In development only, the reset token is returned in the response. In production, connect the reset-token creation to a real email provider before enabling password recovery.
- Checkout records the chosen payment method and order; it does not charge a card or verify a mobile-money transfer. Connect a payment provider and verify signed provider webhooks before treating orders as paid.
- This API is ready to consume, but the current Flutter screens still use in-memory mock services. Pointing the app at this API requires replacing those mock service calls with HTTP requests and storing the returned bearer token.
