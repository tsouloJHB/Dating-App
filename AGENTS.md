# JustHookups: Master Development Documentation (V 1.2.0)

**Project Identity:** JustHookups  
**Status:** Architecture & UI Source of Truth (SSOT)  
**Primary Stack:** Flutter (Riverpod) + Hono (Cloudflare Workers) + Neon Postgres

---

## 0. Design Screen References (`templets/`)

Use the files under `templets/` as the canonical screen-design reference when building and reviewing Flutter UI.

* **Sign in:** `templets/sign_in_light_mode/code.html`
* **Sign up:** `templets/sign_up_light_mode/code.html`
* **Discover (list/light):** `templets/discover_light_mode/code.html`
* **Discover profile card:** `templets/discover_profile_card/code.html`
* **Who liked me:** `templets/who_liked_me_light_mode/code.html`
* **Profile visitors:** `templets/profile_visitors_light_mode/code.html`
* **Matches grid:** `templets/matches_grid_light_mode/code.html`
* **Activity/messages:** `templets/activity_messages/code.html`
* **Profile detail:** `templets/profile_detail_view/code.html`
* **Theme direction:** `templets/midnight_crimson/DESIGN.md`, `templets/obsidian_ember/DESIGN.md`

Rule: for any new or updated screen, the implementation must match the closest `templets/` reference unless product requirements explicitly override it.

---

## 1. Visual Identity & Design System

### 1.1 Color Palette & Theme Modes
| Element | Dark Mode (Default) | Light Mode |
| :--- | :--- | :--- |
| **Background** | `#000000` (Pure Black) | `#FFFFFF` (Pure White) |
| **Surface/Cards** | `#121212` (Dark Grey) | `#F5F5F5` (Light Grey) |
| **Primary Action** | `#FF0000` (Vibrant Red) | `#E60000` (Deep Red) |
| **Premium Accent** | `#FFD700` (Gold) | `#D4AF37` (Metallic Gold) |
| **Text Primary** | `#FFFFFF` | `#1A1A1A` |

### 1.2 Aesthetic Guidelines
* **Vibe:** High-Contrast, Premium, Modern, Bold.
* **Typography:** Bold sans-serif (Inter/Montserrat) for headers; clean legible sans-serif for body.
* **Components:** 24dp border radius for cards. High-density blur (`sigma: 15`) for locked content.
* **Animations:** Hero transitions for profile media; physics-based card swiping.

---

## 2. Technical Stack & Packages

### 2.1 Frontend (Flutter)
| Category | Package | Purpose |
| :--- | :--- | :--- |
| **State Management** | `flutter_riverpod`, `riverpod_generator` | Reactive logic & dependency injection. |
| **Networking** | `dio` | API communication with Hono (Interceptors for Auth). |
| **Hardware/OS** | `location` | Geolocation for discovery & distance logic. |
| **Notifications** | `flutter_local_notifications` | Real-time match/message alerts. |
| **Persistence** | `shared_preferences` | Local storage for JWTs and Theme mode. |
| **UI Utilities** | `cached_network_image`, `flutter_blurhash` | Performance-driven media rendering & blurs. |
| **Payments** | `in_app_purchase` | Google Play Subscription integration. |
| **Data Models** | `freezed`, `json_serializable` | Immutable type-safe models. |

### 2.2 Backend (Cloudflare Workers)
* **Runtime:** Node.js (via Hono).
* **Database:** **Neon Postgres** (Serverless).
* **ORM:** **Drizzle** (Ultra-lightweight for Edge).
* **Auth:** **Better Auth** (Session/Token management).
* **Media:** **Cloudflare R2** (Storage) + **Cloudflare Images** (On-the-fly resizing).

---

## 3. Screen Specifications & Feature Logic

### 3.1 Authentication & Onboarding
* **Flow:** Splash -> Welcome -> Sign Up (Email/Password) -> Profile Setup.
* **Profile Setup:** * Name, DOB (Age check), Gender.
    * **Sexual Orientation:** Straight, Couple, Gay, Bi, etc.
    * **Media:** Minimum 1 photo upload to R2.
* **Permissions:** Explicit request for Location (Discovery) and Notifications.

### 3.2 Main Navigation (4 Items)

#### I. Discover (Fire Icon)
* **Logic:** Fetch 8 profiles via `POST /api/discover` (see `docs/API_CONTRACT.md`). 
* **Filter:** Distance (KM slider) and Age Range.
* **Action:** Swipe Left (X) to mark as seen; Swipe Right (Heart) to Like.
* **Empty State:** "No new people around you" with a Refresh option.

#### II. Inbox Hub (Chat Icon)
* **Who Liked Me:** Grid view. **PREMIUM GATE:** Blurred for free users. Navigation to profile triggers Subscription Screen.
* **Profile Visitors:** Grid view. **PREMIUM GATE:** Blurred for free users.
* **Matches:** Horizontal list of mutual likes.
* **Messages:** List of threads sorted by `last_message_at` snippet.

#### III. Profile Detail View (External)
* **UI:** Hero image, Action buttons (Like/Message), Media thumbnails.
* **Premium Gate (Media):** Index 0 image is free. Index 1+ (Photos/Videos) are locked (Blur + Subscription trigger).
* **Premium Gate (Chat):** If no mutual match, tapping "Message" triggers Subscription Screen.
* **State:** Heart icon is **Full Red** if the user already likes this profile.

#### IV. My Profile (User Icon)
* **Header:** User image with "Edit Profile" (Add/Delete images).
* **Discovery Settings:** Sliders for Distance and Age. Orientation picker.
* **App Settings:** Theme Toggle (Dark/Light), Push Notifications toggle, Feedback (Mail).
* **Subscription:** View Google Subscription details.
* **Account:** Profile Verification, Logout, Hide Account (Soft delete), Delete Account (Hard purge).

---

## 4. Riverpod Architecture (Functional DDD)

Directory structure for `/lib`:

```text
lib/
├── core/
│   ├── theme/           # AppTheme logic (Dark/Light/Red/Gold)
│   ├── network/         # Dio client & Auth interceptors
│   └── constants/       # API endpoints, UI constants
├── features/
│   ├── auth/            # Better Auth implementation
│   ├── discover/        # Swipe logic, location providers
│   ├── activity/        # Who Liked Me, Visitors providers
│   ├── chat/            # Real-time message & R2 logic
│   ├── premium/         # IAP service & Gating controllers
│   └── profile/         # Settings & User CRUD
├── shared/              # Custom Red Buttons, Blur Widgets
└── main.dart