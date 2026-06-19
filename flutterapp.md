# JustHookups: Complete Flutter & Backend Documentation

**Version:** 1.1.0  
**Design System:** High-Contrast Premium / Modern  
**Primary Stack:** Flutter (Riverpod) + Hono (Cloudflare Workers) + Neon Postgres

---

## 0. Design Screen References (`templets/`)

Use the files in `templets/` as the canonical visual reference for screen layout, spacing, hierarchy, and states while building Flutter UI.

- Sign in: `templets/sign_in_light_mode/code.html`
- Sign up: `templets/sign_up_light_mode/code.html`
- Discover (list/light): `templets/discover_light_mode/code.html`
- Discover profile card: `templets/discover_profile_card/code.html`
- Who liked me: `templets/who_liked_me_light_mode/code.html`
- Profile visitors: `templets/profile_visitors_light_mode/code.html`
- Matches grid: `templets/matches_grid_light_mode/code.html`
- Activity/messages: `templets/activity_messages/code.html`
- Profile detail: `templets/profile_detail_view/code.html`
- Theme direction: `templets/midnight_crimson/DESIGN.md`, `templets/obsidian_ember/DESIGN.md`

Implementation note: when there is any visual mismatch between a screen implementation and its template, update the screen to match the corresponding `templets/` reference unless product requirements explicitly override it.

---

## 1. Visual Identity & Design System

### 1.1 Color Palette
| Element | Dark Mode (Default) | Light Mode |
| :--- | :--- | :--- |
| **Background** | #000000 (Pure Black) | #FFFFFF (Pure White) |
| **Surface/Cards** | #121212 (Dark Grey) | #F5F5F5 (Light Grey) |
| **Primary Action** | #FF0000 (Vibrant Red) | #E60000 (Deep Red) |
| **Premium Accent** | #FFD700 (Gold) | #D4AF37 (Metallic Gold) |
| **Text Primary** | #FFFFFF | #1A1A1A |

### 1.2 Aesthetic Guidelines
* **Typography:** Bold sans-serif (e.g., Montserrat or Inter) for headers.
* **Components:** Large border radius (24dp) for cards, minimal borders, heavy use of Gaussian Blur for gated content.
* **Animations:** Smooth card stacks (Swipe), Hero transitions for profile images.

---

## 2. Flutter Technical Stack (Packages)

Add these to your `pubspec.yaml`:

| Category | Package | Purpose |
| :--- | :--- | :--- |
| **State Management** | `flutter_riverpod`, `riverpod_annotation` | Logic & Data flow. |
| **Networking** | `dio` or `http` | API communication with Hono. |
| **Hardware/OS** | `location` | Fetching lat/long for discovery. |
| **Notifications** | `flutter_local_notifications` | Real-time match/message alerts. |
| **Persistence** | `shared_preferences` | Storing Auth tokens & Theme preference. |
| **UI Utilities** | `flutter_blurhash`, `cached_network_image` | Image loading & Premium blurs. |
| **Payments** | `in_app_purchase` | Google Play Subscription handling. |

---

## 3. Screen Flow & Logic

### 3.1 Authentication Flow (Onboarding)
1.  **Welcome Screen:** High-impact branding with "Get Started" (Red Button).
2.  **Registration:** Multi-step form (Email, Password via Better Auth).
3.  **Profile Setup:** * Name, DOB (Age calculation), Gender selection.
    * **Orientation:** "I am..." (Straight, Couple, Gay, etc.).
    * **Media Upload:** Minimum 1 photo required (Uploads to Cloudflare R2).
4.  **Permissions:** Request **Location** and **Notifications** access.

### 3.2 Main Navigation (4 Menu Items)

#### I. Discover (Fire Icon)
* **Function:** Swipe-based matching.
* **Features:** Filter by Distance (km) and Age range.
* **Logic:** Fetches 8 profiles at a time (Lazy Loading). Uses `location` to calculate distance from current user.

#### II. Inbox Hub (Chat Icon)
* **Who Liked Me:** Grid view. **Premium Gate:** Images blurred. Tapping redirects to Gold-themed Subscription Page.
* **Profile Visitors:** Same as above.
* **Matches:** Horizontal list of active mutual likes.
* **Messages:** List of threads sorted by newest activity.

#### III. Profile Detail (Public View)
* Opens when a profile is tapped from Discover or Inbox.
* **Premium Gate (Media):** Main photo is free. Any additional thumbnails in the gallery are locked for Free users.
* **Premium Gate (Chat):** "Message" button triggers Subscription screen if no mutual match exists.

#### IV. My Account (User Icon)
* **Theme Toggle:** Switch between Dark and Light mode.
* **Edit Profile:** Update bio, images, and discovery filters.
* **Subscription Management:** Displays current tier status with a "Go Gold" CTA for Free users.
* **Settings:** Toggle `flutter_local_notifications`, Logout, and Delete Account.

---

## 4. Riverpod Architecture (Layered DDD)

Organize your `/lib` folder by **Feature** to ensure the AI agents can navigate the codebase easily:

* **`domain/`**: Pure Dart models (User, Match, Message) using `@freezed`.
* **`data/`**: Data sources (API clients) and Repositories (handling the `http` logic).
* **`application/`**: Services (e.g., `LocationService`, `AuthService`).
* **`presentation/`**: 
    * **Providers:** State Notifiers (e.g., `SwipeNotifier`, `ChatNotifier`).
    * **Widgets:** The actual UI screens with theme-aware colors.

---

## 5. Backend Hooks (Cloudflare/Hono)
* **Location Queries:** Use PostGIS (via Neon) to find users within the `discovery_radius`.
* **Push Notifications:** Triggered by Hono via Firebase Cloud Messaging (FCM) when a match occurs or a message is sent.
* **Media Policy:** Cloudflare R2 bucket should have separate folders for `public/` (first photo) and `private/` (extra media) to enforce premium access at the CDN level if possible.

---

## 6. Global Theme Logic
Implement a `ThemeData` provider that watches the user's settings:

```dart
// Example logic
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFFE60000), // Primary Red
  scaffoldBackgroundColor: Colors.white,
  // ... Gold accents for Premium cards
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFFFF0000), // Vibrant Red
  scaffoldBackgroundColor: Colors.black,
  // ... Gold accents for Premium cards
);