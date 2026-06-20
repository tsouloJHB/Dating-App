# JustHookups Flutter App

A premium social discovery platform built with Flutter and Riverpod.

## Project Structure

```
lib/
├── core/
│   ├── theme/           # App theming (light/dark modes)
│   ├── network/         # Dio HTTP client & interceptors
│   ├── constants/       # API constants & configuration
│   └── services/        # Location, Notifications services
├── domain/
│   └── models/          # Freezed data models
├── data/
│   ├── sources/         # API data sources
│   └── repositories/    # Data layer abstractions
├── features/
│   ├── auth/            # Authentication
│   ├── discover/        # Swipe & discovery
│   ├── activity/        # Likes/visitors
│   ├── chat/            # Messaging
│   ├── premium/         # IAP & subscriptions
│   └── profile/         # User settings & profile
├── shared/
│   └── widgets/         # Reusable UI components
└── main.dart            # App entry point
```

## Features

### 1. Authentication
- Email/Password signup via Better Auth
- Session & token management
- Profile completeness verification

### 2. Discovery
- Swipe-based profile matching
- Distance & age filtering
- Location-based search

### 3. Activity Hub
- Who Liked Me (Premium gate)
- Profile Visitors (Premium gate)
- Matches overview

### 4. Messaging
- Real-time message threads
- Last message preview
- Unread count tracking

### 5. Premium
- Google Play Subscription integration
- Premium content gating
- Blur effect on locked media

### 6. My Profile
- Profile editing & media upload
- Discovery settings
- Account & subscription management

## Tech Stack

- **State Management**: Flutter Riverpod
- **Networking**: Dio + Better Auth (Backend)
- **Hardware**: Location for geolocation
- **Notifications**: Flutter Local Notifications
- **Persistence**: SharedPreferences
- **Data Models**: Freezed + JSON Serializable
- **UI Navigation**: GoRouter

## Getting Started

### Prerequisites
- Flutter 3.16.0+
- Dart 3.2.0+

### Installation

1. **Install dependencies:**
```bash
flutter pub get
```

2. **Generate code (freezed, json_serializable):**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **Run the app:**
```bash
flutter run
```

## Environment Setup

Create a `.env` file in the app root (optional):
```
API_BASE_URL=https://api.justhookups.dev
GOOGLE_PLAY_SUBSCRIPTION_ID=your_subscription_id
```

### Run By Environment (dart-define)

The app uses compile-time defines:

- `API_BASE_URL` for backend origin
- `ENVIRONMENT` for environment mode (`development`, `preprod`, `production`)

From repository root, use the ready-made scripts:

```bash
pnpm run flutter:dev
pnpm run flutter:dev:android
pnpm run flutter:preprod
pnpm run flutter:prod
```

Build APKs:

```bash
pnpm run flutter:build:apk:preprod
pnpm run flutter:build:apk:prod
```

Equivalent manual commands inside `apps/flutter_app`:

```bash
# Local development (web/iOS simulator)
flutter run --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://localhost:8787

# Local development (Android emulator)
flutter run --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=http://10.0.2.2:8787

# Preprod worker
flutter run --dart-define=ENVIRONMENT=preprod --dart-define=API_BASE_URL=https://dating-site-api.thabangsoulo.workers.dev

# Production
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://api.justhookups.dev
```

### Local Debugging Notes

- Android emulator cannot reach host `localhost`; use `10.0.2.2`.
- Physical devices cannot use `localhost`; use your machine LAN IP.
- For Flutter web, server `CORS_ORIGIN` must exactly match browser origin.
- In debug logs, startup prints active `environment` and resolved `baseUrl`.

## Project Architecture

The app follows **Clean Architecture** with **Domain-Driven Design**:

- **Domain Layer**: Pure Dart models + business logic interfaces
- **Data Layer**: Repository implementations + API clients
- **Presentation Layer**: Riverpod providers + UI screens

## Theme System

### Colors
- **Dark Mode**: Pure black background with red primary actions
- **Light Mode**: Pure white background with deep red actions
- **Premium Accent**: Gold (#FFD700 / #D4AF37)

### Typography
- **Headers**: Montserrat Bold/SemiBold
- **Body**: Montserrat Regular

### Components
- **Border Radius**: 24dp for cards, 12dp for buttons
- **Blur**: 15px Gaussian blur for premium content

## API Integration

The app communicates with the Hono backend via REST API:

- Base URL: `https://api.justhookups.dev`
- Auth: Bearer token (JWT) in Authorization header
- Interceptors: Auto token refresh, error handling

## Premium Gating

Free users see blurred content for:
- Additional photos (beyond first)
- Who Liked Me grid
- Profile Visitors grid

Tapping locked content triggers subscription flow.

## Navigation

Uses `GoRouter` for declarative routing:
- `/` - Welcome
- `/home` - Main tab navigator
- `/discover` - Discovery/swipe
- `/activity` - Likes/visitors
- `/chat` - Messages
- `/profile` - My profile & settings
- `/premium` - Subscription screen

## License

Private Project - JustHookups
