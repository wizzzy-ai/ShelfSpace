# ShelfSpace Project Documentation

ShelfSpace is a full-stack bookstore application designed for browsing, searching, and purchasing books. It combines a Flutter frontend with a Node.js backend and SQLite persistence to deliver a complete commerce experience with user authentication, shopping cart, wishlist, reviews, order tracking, and admin tools.

## 1. Overview

ShelfSpace provides a modern bookstore experience with:

- Book browsing and search
- Genre and feature-based filtering
- User authentication and profile management
- Wishlist and cart workflows
- Reviews and ratings
- Order placement and tracking
- Admin dashboard and catalog management

This project is primarily built using:
- Flutter and Dart for the frontend
- Express.js for the backend API
- SQLite for local data persistence
- Provider for state management

## 2. Project Goals

The project aims to:
- Deliver a polished digital bookstore experience
- Support a complete customer purchase lifecycle
- Provide backend persistence for real product data
- Demonstrate a scalable full-stack architecture for a commerce app
- Be easy to run locally for demos and prototyping

## 3. Technology Stack

### Frontend
- Flutter
- Dart
- Provider
- Google Fonts
- Cached Network Image
- HTTP client

### Backend
- Node.js
- Express.js
- SQLite
- JWT authentication

### Supported platforms
- Android
- iOS
- Web
- Linux
- macOS
- Windows

## 4. Repository Structure

```text
ShelfSpace/
├── .github/
├── android/
├── assets/
├── backend/
│   ├── database/
│   ├── src/
│   ├── .env.example
│   ├── package.json
│   ├── README.md
│   └── package-lock.json
├── ios/
├── lib/
│   ├── core/
│   ├── models/
│   ├── profile_orders/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── main.dart
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── .gitignore
├── .metadata
├── README.md
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
└── ...
```

### Main folders
- `lib/`: Flutter app source
- `backend/`: REST API and SQLite database logic
- `assets/`: visual resources and images
- `test/`: test files
- platform folders: Android, iOS, Linux, macOS, and Windows support files

## 5. Features

### Customer features
- Browse the public catalog
- Search and filter books
- View book details and reviews
- Add books to wishlist
- Add books to cart
- Checkout and place orders
- View order history
- Update profile information

### Admin features
- View summary dashboard metrics
- Manage the book catalog
- Update order statuses
- Review user activity and customer data

## 6. Setup and Installation

### Prerequisites
Before running the project, install:
- Flutter SDK
- Dart SDK
- Node.js 20+
- npm
- VS Code, Android Studio, or another IDE

### Frontend setup
From the project root:

```bash
flutter pub get
flutter run
```

### Backend setup
From the `backend` directory:

```bash
npm install
cp .env.example .env
npm run seed:admin
npm run dev
```

Notes:
- The backend listens on `http://localhost:3000`
- SQLite creates the database file automatically on first run
- Set `JWT_SECRET` to a strong secure value
- Set `ADMIN_EMAIL` and `ADMIN_PASSWORD` before seeding the admin user

## 7. Environment Configuration

The backend uses environment variables stored in `backend/.env`.

Typical values include:
- `JWT_SECRET`
- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`
- `DATABASE_FILE`
- `CLIENT_ORIGIN`

### API URL conventions
- Android emulator: `http://10.0.2.2:3000`
- iOS simulator / desktop: `http://localhost:3000`
- Physical device: use your machine's LAN IP address

## 8. Authentication Model

The app uses bearer-token authentication for protected routes. Users can register, sign in, update their profiles, change passwords, and manage orders and reviews.

Customer authentication allows:
- Registration
- Login
- Profile read/update
- Password changes
- Cart, wishlist, and order actions

Admin authentication allows:
- Summary dashboard access
- Catalog management
- Order status updates
- User record management

## 9. Backend API Overview

The backend exposes a REST API under `/api`. Common endpoints include:

- `GET /api/health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/books`
- `GET /api/books/:id`
- `GET /api/cart`
- `POST /api/orders`
- `GET /api/admin/summary`

A complete API reference is available in:
- `backend/README.md`

## 10. Development Workflow

1. Start the backend
2. Point the frontend to the local backend URL
3. Run the Flutter app
4. Test browsing, cart, wishlist, and ordering flows
5. Validate admin flows with the seeded admin account

## 11. Testing and Validation

The project includes:
- Flutter test support
- Linting configuration
- Local backend validation steps

Recommended checks:
- App loads successfully
- Health endpoint is reachable
- Registration and login work correctly
- Cart and wishlist actions work
- Orders can be created and tracked
- Admin features are restricted to authorized users

## 12. FAQ

### What is ShelfSpace?
ShelfSpace is a bookstore application that lets users browse books, add items to cart or wishlist, place orders, and manage profiles. It also includes an admin area for catalog and order management.

### Is this app a mobile app or a full-stack project?
It is a full-stack project with a Flutter frontend and an Express.js backend powered by SQLite.

### What technology is used for the frontend?
The frontend uses Flutter and Dart with Material-based UI patterns and Provider state management.

### What technology is used for the backend?
The backend uses Express.js, JWT authentication, and SQLite persistence.

### How do I run the app locally?
Run the Flutter app with:

```bash
flutter pub get
flutter run
```

Then start the backend in the `backend` directory.

### How do I run the backend?
From the `backend` directory:

```bash
npm install
cp .env.example .env
npm run seed:admin
npm run dev
```

### Where does the app fetch data from?
The frontend communicates with the backend API in the `backend` folder. In development, it typically uses `localhost` or an emulator-safe host such as `10.0.2.2`.

### What is the default admin user?
The admin account is seeded from environment variables such as `ADMIN_EMAIL` and `ADMIN_PASSWORD`.

### Why do I need to use `10.0.2.2`?
Android emulators cannot reach your local machine using `localhost` the same way real devices do. `10.0.2.2` is the standard alias used to reach the host machine from an Android emulator.

### Can I use this as a starter project?
Yes. The project is structured as a practical e-commerce and bookstore prototype and can be extended with payments, better search, analytics, and deployment features.

### Does the app support web deployment?
Yes. The project includes Flutter web support.

### Is this project production-ready?
It is a functional prototype and is suitable for learning, experimentation, and extension. Production deployment would still require additional security and operational hardening.

### Where is the API reference?
The main backend reference is in:
- `backend/README.md`

### Why do some screens still use mock data?
Some screens may still rely on mock services until the frontend is fully connected to the backend API.

## 13. Roadmap Ideas

Potential future improvements:
- Real payment integration
- Better analytics and reporting
- Search optimization
- More advanced recommendations
- Multi-language support
- Deployment automation with Docker and CI/CD

## 14. Summary

ShelfSpace is a practical full-stack bookstore application built with Flutter and Node.js. It combines a polished user experience with backend services, persistence, and admin features. It is suitable for learning, prototyping, and extending into a larger commerce platform.

For the fastest setup, start with the frontend and backend installation steps above, then validate the main user journeys before exploring admin functionality.
