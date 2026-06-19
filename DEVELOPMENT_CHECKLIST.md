# JustHookups — Development Checklist

Use this list to track what is left before the product is **feature-complete and runnable** end-to-end (Flutter client + Hono on Workers + Neon + R2 + Google Play). Items are grouped so you can assign backend vs frontend work in parallel.

**Sources of truth:** `AGENTS.md`, `docs/API_CONTRACT.md`, `flutterapp.md`, the `templets/` design references, and the current API stubs under `apps/server/src/routes/`.

## Current Progress Snapshot (Apr 5, 2026)

- [x] Flutter API paths aligned to server `/api/*` routes (`apps/flutter_app/lib/core/constants/api_constants.dart`).
- [x] Auth datasource parsing hardened for Better Auth payload/session variations (`apps/flutter_app/lib/data/sources/auth_data_source.dart`).
- [x] DB-backed discover route implemented with limit 8 and interaction exclusion (`apps/server/src/routes/discover.ts`).
- [x] Validation run: server type-check passes (`pnpm -F server check-types`), Flutter has no compile errors (analyzer infos only).
- [x] **Interactions endpoint implemented** (`POST /api/interactions` — LIKE/PASS + reciprocal match creation; `GET /api/interactions/mine` — history).
- [x] **Flutter interactions datasource & Riverpod provider** (`lib/data/sources/interactions_data_source.dart`, `lib/features/interactions/interactions_provider.dart`).
- [x] **Inbox endpoints implemented** (`GET /api/inbox/likes-in`, `GET /api/inbox/visitors` — paginated, with auth guard and profile data).
- [x] **Matches endpoint implemented** (`GET /api/matches` — paginated mutual likes with match timestamp).
- [x] **Flutter inbox/matches datasources & Riverpod providers** (`lib/data/sources/inbox_data_source.dart`, `lib/data/sources/matches_data_source.dart`, updated `lib/features/activity/activity_provider.dart`).
- [x] **Profile view logging implemented** (`POST /api/users/:userId/views` — logs profile views in `profile_views` table).
- [x] **Public profile endpoint implemented** (`GET /api/users/:userId` — returns profile detail with photos, bio, isPremium flag).
- [x] **Flutter users datasource & Riverpod providers** (`lib/data/sources/users_data_source.dart`, updated `lib/features/profile/profile_provider.dart` with `userDetailProvider` + auto-logging).
- [x] **Auth E2E UI implemented** (`sign_in_screen.dart`, `sign_up_screen.dart`, `welcome_screen.dart` — all wired to `authStateProvider`, form validation, friendly errors).
- [x] **Auth routing + guard** (`main.dart` — `/sign-in`, `/sign-up` routes; GoRouter redirect guards protected routes; session restore via `AuthNotifier` bootstrap after Dio init).
- [x] **Discover UI** — Swipeable profile cards with LIKE/PASS gestures + action buttons, match-created snackbar, empty state, error/retry view; wired to `discoverStateProvider` + `interactionsDataSourceProvider`.
- [x] **Activity Hub UI** — 3-tab screen (Liked Me / Visitors / Matches) with photo grid, premium blur overlay for FREE tier on Liked Me + Visitors, empty states, loading states; wired to `likesInProvider`, `visitorsListProvider`, `matchesListProvider`.
- [x] **Profile detail view** — Hero image, photo thumbnail strip (index 1+ blurred for FREE), Like + Message action buttons, info chips, bio, premium badge; tappable from Discover cards and Activity grid; auto-logs profile view; Like button turns red on tap and shows match snackbar; Message locked behind match/premium gate.
- [x] **My Profile & Settings screen** — Full `ProfileScreen` replacing stub: avatar header (initials), bio inline editor (`PUT /api/account/profile`), discovery settings (orientation chip picker, age range `RangeSlider`, radius `Slider`); App Settings (dark/light theme toggle via `themeProvider`); Account section (Logout, Hide account `PATCH /api/account/hide`, Delete account `DELETE /api/account`) each with confirmation dialog. `hideAccount()` + `deleteAccount()` wired through data source → repository → `ProfileNotifier`; `accountHide` + `accountDelete` constants added to `api_constants.dart`.
- [x] **Messaging + media attachments** — Server messaging endpoints (`GET /api/messages/threads`, `GET/POST /api/messages/:threadId`) implemented with auth and FREE/PREMIUM gate; media upload endpoint (`POST /api/media/upload`) implemented with R2 storage + persisted `media` row + retrievable URL (`GET /api/media/:key`). Flutter chat now supports picking photo/video from camera/gallery, uploading via media API, and sending attachment URL messages.
- [x] **Premium paywall foundation** — Billing verification and subscription status endpoints are active on the server; Flutter `PremiumScreen` now renders a functional Go Gold paywall with current-plan state, benefit cards, unlock/cancel actions, and app-wide tier refresh after changes.
- [x] **Reusable premium lock UI** — shared `PremiumLockedOverlay` and `PremiumUnlockBanner` extracted into `lib/shared/widgets/app_widgets.dart` and used by Activity grids + Profile Detail locked gallery thumbnails.
- [x] **Signup now completes domain profile setup** — after Better Auth sign-up succeeds, Flutter immediately calls `PUT /api/account/profile` to create/update the `profile` row with selected `gender` + `preference`; server `account.ts` now accepts/stores `gender` and returns it in the profile payload.
- [x] **Onboarding first-photo requirement** — `SignUpScreen` now requires selecting a first photo (camera/gallery), previews it locally, and blocks completion until the upload succeeds; auth redirect is deferred with `profileSetupPending` until the upload finishes.
- [x] **Onboarding permissions prompts** — after photo upload during sign-up, app now shows rationale dialogs and requests Location + Notifications permissions; denial is handled gracefully with user feedback.
- [x] **Location persistence during onboarding** — server `PUT /api/account/profile` now accepts/stores `latitude` + `longitude` (`location_lat/location_lng`), and sign-up flow syncs current coordinates right after location permission is granted.
- [x] **Discovery preference/gender filtering** — `POST /api/discover` now filters targets by sexual orientation + gender compatibility (e.g., Straight Female sees Male targets; Gay Male sees Male targets with compatible preferences; Bi sees all with matching orientation).
- [x] **Country-based region isolation** — `profile.country` column (ISO 3166-1 alpha-2) added to DB with index. Server auto-detects country from Cloudflare's `cf-ipcountry` request header on every `PUT /api/account/profile` call (no client changes required). Discover filters results to the same country as the requesting user; profiles without a country are excluded when filtering is active to prevent cross-border leakage. Country is also returned in discover profile payloads and account profile responses.
- [x] **Distance ordering/filtering + discovery radius** — `profile.discovery_radius` (int, km, default 50), `min_age_range`, and `max_age_range` columns added to DB. Discover computes Haversine distance, filters to `≤ discoveryRadius` km, orders by distance ASC, and returns `distanceKm` (1 dp) in every profile payload.
- [x] **My likes endpoint + Flutter provider** — added `GET /api/interactions/likes-out` for outgoing LIKE history, enriched with profile/media payloads and `likedAt`; Flutter now exposes it via `InboxDataSource.getMyLikes()` and `myLikesListProvider` for future UI wiring.
- [x] **Discover frontend completed** — added a dedicated location provider with one-shot GPS refresh + backend sync, filter bottom sheet (distance + age range) persisted to profile settings, and cursor pagination in 8-profile batches with auto-prefetch as the swipe stack runs low.

## Design Screen References (`templets/`)

Use the HTML files under `templets/` as the visual reference when implementing or reviewing Flutter screens.

- Auth screens: `templets/sign_in_light_mode/code.html`, `templets/sign_up_light_mode/code.html`
- Discover screens: `templets/discover_light_mode/code.html`, `templets/discover_profile_card/code.html`
- Inbox/activity screens: `templets/who_liked_me_light_mode/code.html`, `templets/profile_visitors_light_mode/code.html`, `templets/matches_grid_light_mode/code.html`, `templets/activity_messages/code.html`
- Profile detail screen: `templets/profile_detail_view/code.html`
- Global visual direction: `templets/midnight_crimson/DESIGN.md`, `templets/obsidian_ember/DESIGN.md`

Checklist rule: for any new or updated screen PR, confirm the UI matches the closest `templets/` reference before marking the task complete.

---

## 0. Foundation (do first)

- [x] **Monorepo & env:** Document and validate all required env vars (Neon `DATABASE_URL`, Better Auth secrets/URLs, `CORS_ORIGIN`, Wrangler R2 binding, optional `CLOUDFLARE_API_TOKEN` for Alchemy). See `docs/ENVIRONMENT.md`, `pnpm env:check`, and `assertWorkerEnv` in `apps/server/src/index.ts`.
- [x] **API contract:** Publish a single contract (OpenAPI or markdown) and align it with the app (e.g. AGENTS mentions `POST /discover`; server today uses `GET /api/discover` — pick one and mirror in Flutter `core/constants`). **Done:** `docs/API_CONTRACT.md`; canonical **`POST /api/discover`** (optional empty **`GET /api/discover`**); Flutter `api_constants.dart` + data sources aligned.
- [x] **Database:** Run Drizzle migrations / `db:push` for Better Auth tables + domain tables (`profile`, `interactions`, `matches`, `media`, `messages`, `profile_views`). **Done:** initial SQL in `packages/db/src/migrations/` (`0000_*.sql`); apply with `pnpm db:migrate` (or regenerate with `pnpm db:generate`). `pnpm db:push` remains available for schema sync without new migration files. Requires `DATABASE_URL` in `apps/server/.env` (see `docs/ENVIRONMENT.md`).
- [x] **Auth E2E:** Sign-up, sign-in, session/cookies or Bearer flow working from a real device/emulator through Dio interceptors. **Done:** Better Auth **`bearer()`** plugin (`packages/auth`); CORS **`exposeHeaders: set-auth-token`**; Flutter persists token from header/body, sends **`Authorization: Bearer`**, restores session in **`AuthNotifier._bootstrap`** after **`dioProvider`** loads (`main.dart` **`_AppBootstrap`**).
- [x] **Error & loading UX:** Global handling for 401, 403 (premium), 429, and network errors on both sides. **Flutter:** `ApiException` + `ErrorInterceptor` (`lib/core/network/api_exception.dart`, `dio_client.dart`); 401 clears token and **`AuthSessionBridge`** resets auth (skipped on sign-in/sign-up paths). **Server:** JSON **`onError`** / **`notFound`** in `apps/server/src/index.ts` (`{ "error": "..." }`).

---

## 1. Backend — Core platform

### 1.1 Auth & user lifecycle

- [x] **Better Auth:** Email/password fully wired — datasource + Sign In / Sign Up UI implemented and routed.
- [x] **Profile row:** Create/update `profile` on signup completion (tier `FREE`, gender, preference, `is_active`, optional bio).
- [x] **Session security:** Cookie/`Secure`/`SameSite` behavior verified for your production domains (Workers + mobile WebView if applicable). **Done:** `packages/auth` derives cookie attrs from `BETTER_AUTH_URL` (`https` → `None`+`Secure`; `http` local → `Lax` without `Secure`); documented in `docs/ENVIRONMENT.md`. Mobile remains bearer-first.

### 1.2 Location & discovery

- [x] **Persist location:** `PUT /api/account/profile` now accepts `latitude`/`longitude` and stores on `profile` (`location_lat`/`location_lng`); onboarding flow syncs coordinates after location permission grant.
- [x] **Discovery query (base implementation):** Exclude users already in `interactions` for the actor and enforce **limit 8** with keyset/cursor pagination. Implemented in `apps/server/src/routes/discover.ts`.
- [x] **Discovery query (remaining):** Respect `preference` / gender filters. Filters targets by sexual orientation compatibility + gender matching (Straight shows opposite gender, Gay shows same gender, Bi shows all with compatible preferences).
- [x] **Country-based region isolation:** `profile.country` (ISO 3166-1 alpha-2) auto-populated from Cloudflare `cf-ipcountry` request header on every `PUT /api/account/profile` write; indexed for fast filtering. `POST /api/discover` WHERE clause restricts results to same-country profiles; actors/targets without country set are excluded when filtering is active.
- [x] **`POST /api/discover`:** Returns profile payload with pagination (`profiles`, `nextCursor`, `limit`) and profile media URLs.
- [x] **Distance ordering/filter + discovery radius:** `profile.discovery_radius` (default 50 km), `min_age_range`, and `max_age_range` added to schema, persisted via `PUT /api/account/profile`. Discover computes Haversine distance, filters by `≤ discoveryRadius` km, orders by distance ASC, returns `distanceKm` (1 dp) in payload. Request can override stored coords and radius for real-time accuracy.
- [x] **Discover payload enhancements:** Computed `distanceKm` (1 dp) and `country` included in every profile response.

### 1.3 Interactions, matches, visitors

- [x] **Swipe actions:** `POST /api/interactions` — record `LIKE` or `PASS`; idempotent or upsert per `(actor_id, target_id)`. ✅ Implemented with upsert and reciprocal match creation on mutual LIKE.
- [x] **Match creation:** On reciprocal `LIKE`, insert `matches` with canonical `(user_1, user_2)` ordering. ✅ Automatic via `POST /api/interactions`.
- [x] **Profile view logging:** When someone opens a profile detail, record `profile_views` (for Visitors tab). ✅ Implemented in `POST /api/users/:userId/views` with auto-logging via `userDetailProvider`.
- [x] **Who liked me / visitors:** `GET /api/inbox/likes-in` and `GET /api/inbox/visitors` — **limit 8**, cursor; include `tier` or flags so the client can blur for `FREE`. ✅ Implemented with auth guard, keyset pagination, and profile data (isPremium flag for gating).

### 1.4 Lists & profile read APIs

- [x] **Matches list:** `GET /api/matches` — paginated, limit 8. ✅ Implemented with keyset pagination and mutual-like query.
- [x] **My likes:** `GET /api/interactions/likes-out` returns paginated “profiles I liked” with profile/media fields and `likedAt`; Flutter datasource/provider added for consumption.
- [x] **Public profile:** `GET /api/users/:id` — returns safe fields + media list + `isPremium` tier flag for gating. ✅ Implemented in `apps/server/src/routes/users.ts`.
- [x] **Edit profile / settings:** `PATCH` user + `profile` (bio, filters: age range, distance, orientation); reorder/delete media metadata. **Done:** `PUT`/`PATCH` `/api/account/profile`, `PATCH` `/api/account/settings` (alias), `PATCH` `/api/account/user` (name/image); `GET` profile returns `interests` + range/radius; Flutter `ApiConstants` + `ProfileDataSource`/`Repository` (delete/reorder/onboarding/user display).

### 1.5 Media (R2 + Images)

- [x] **Upload path:** `POST /api/media/upload` implemented — auth-enforced multipart upload to R2 (`MEDIA_BUCKET`), URL returned and persisted in `media` table; `GET /api/media/:key` serves stored object.
- [x] **Media metadata:** Insert/update `media` rows (`sort_order`, `is_video`); enforce **minimum one photo** at onboarding completion. **Done:** upload uses Drizzle + next `sort_order`; `PATCH /api/media/reorder`, `DELETE /api/media/item/:id`; `POST /api/account/onboarding/complete` returns **400** without media; profile `interests` column + migration `0002_cool_deathbird.sql` (run `pnpm db:migrate`).
- [x] **Cloudflare Images (optional but in spec):** Thumbnail variants (e.g. width 200) for lists to save bandwidth. **Done:** optional **`MEDIA_LIST_THUMB_WIDTH`** + **`photoThumbUrls`** via `/cdn-cgi/image/...` (`apps/server/src/lib/photo-payload.ts`); documented in `docs/ENVIRONMENT.md` / `docs/API_CONTRACT.md`.
- [x] **Premium enforcement (server-side):** For `FREE`, API should not return full URLs or metadata for gallery index > 0 (or return locked placeholders) — don’t rely on UI alone. **Done:** `buildPhotoPayload` redacts indices `> 0` for non-premium viewers on discover, users, inbox, matches, likes-out (`photo-payload.ts` + route wiring).

### 1.6 Messaging

- [x] **Thread list:** `GET /api/messages/threads` — implemented with auth guard, per-partner latest snippet, name/avatar enrichment, sorted by latest activity, keyset cursor by timestamp.
- [x] **History:** `GET /api/messages/:threadId` — implemented with auth guard and cursor pagination; returns oldest-first for chat UI.
- [x] **Send message:** `POST /api/messages/:threadId` — implemented with payload validation, FREE-tier match gate (403 if no match), PREMIUM bypass.
- [x] **Realtime transport:** Polling MVP implemented in Flutter (`ChatScreen` thread list refresh every 8s, `ConversationScreen` history refresh every 3s with thread refresh invalidation). WebSockets/DO + FCM push remains a future upgrade.

### 1.7 Premium & Google Play

- [x] **`POST /api/billing/verify`:** Implemented dev verification flow — validates payload and upgrades `profile.tier` to `PREMIUM` on success.
- [x] **Subscription status endpoint** (optional): `GET /api/billing/subscriptions` implemented and used by Flutter paywall/settings flows.
- [x] **Downgrade / expiry:** Handle revocation or expired subs (cron or verify on critical routes). **Done:** `profile.tier_expires_at` + migration `0003_optimal_mole_man.sql`; `expirePremiumIfNeeded` (`lib/subscription.ts`) on **`GET /api/billing/subscriptions`**, **message send** tier check, and viewer premium resolution; **`POST /api/billing/verify`** sets expiry (`expiresAt` / `expiresInDays`, default 30d); **`DELETE /api/billing/subscriptions`** clears tier + expiry.

### 1.8 Account & compliance

- [x] **Hide account:** `PATCH /api/account/hide` — set `is_active = false`; exclude from discover.
- [x] **Delete account:** `DELETE /api/account` — cascade delete via Better Auth `user` table (FK cascade).
- [x] **Profile verification:** Workflow placeholder implemented — `profile.verification_status` fields added; user-facing endpoints `GET /api/account/verification/status` and `POST /api/account/verification/request` added for manual review pipeline integration.

### 1.9 Observability & hardening

- [x] **Rate limiting** on auth and expensive routes. Implemented in `apps/server/src/lib/rate-limit.ts` (IP bucketed window limiter) and wired in `apps/server/src/index.ts` for `/api/auth/*`, `/api/discover`, `/api/inbox/*`, `/api/matches`, `/api/messages/*`, `/api/media/upload`, `/api/billing/*`.
- [x] **Input validation** (Zod) on all write endpoints. Added/extended validation on remaining write handlers: `messages.post('/:threadId')` recipient/path checks, `users.post('/:userId/views')` path checks, and `media` upload/delete constraints (MIME, size, UUID id) in `apps/server/src/routes/messages.ts`, `apps/server/src/routes/users.ts`, and `apps/server/src/routes/media.ts`.
- [x] **Structured logs** (no secrets); request IDs for support. Implemented `requestIdAndStructuredLog` middleware in `apps/server/src/lib/request-log.ts` and wired in `apps/server/src/index.ts` (JSON logs with `requestId`, method/path/status/duration, user-agent, IP; response header `x-request-id`).

---

## 2. Frontend — Flutter (Riverpod)

### 2.1 App shell & design system

- [x] **Theme:** Dark (default) + light per palette in `AGENTS.md` §1; primary red + gold premium accents. `themeProvider` now defaults to dark and persists user selection via `SharedPreferences`; Profile Settings toggle updates persisted mode.
- [x] **Typography & shapes:** Inter/Montserrat standardized in `AppTheme` (`AppTypography`: Montserrat headings + Inter body) and shared shape tokens added (`AppRadii`); cards/controls aligned to ~24dp across theme and shared widgets.
- [x] **Navigation:** Bottom nav aligned to spec language and iconography: Discover (fire), Inbox hub, Messages, and My Account.

### 2.2 Core infrastructure (`lib/core/`)

- [x] **Dio client:** Base URL, timeouts, auth interceptor (session cookie or token from `shared_preferences`).
- [x] **Constants:** Endpoints matching finalized API (including `/api/...` prefix).
- [x] **Routing:** GoRouter shell present (welcome + home/discover/activity/chat/profile/premium routes).

### 2.3 Onboarding & auth (`features/auth/`)

- [x] **Splash → Welcome → Sign up / Sign in** (Better Auth client).
- [x] **Profile setup:** Name, DOB → age, gender, orientation; validate before continuing.
- [x] **First photo upload** to R2 via backend; block completion until success.
- [x] **Permissions:** Location + notifications prompts with rationale copy.

### 2.4 Discover (`features/discover/`)

- [x] **Location provider:** `location` package wired through `discoverLocationProvider` — one-shot GPS refresh, permission handling, and backend sync via `profileRepository.syncLocation()`.
- [x] **Swipe UI:** Card stack with gesture drag, left = PASS, right = LIKE, action buttons, match snackbar, empty state, and profile navigation.
- [x] **Filters UI:** Distance (km) + age range bottom sheet implemented in Discover and persisted to backend profile settings.
- [x] **Pagination:** Requests batches of **8** with cursor support and auto-prefetch when the swipe stack gets low; empty state still offers refresh.

### 2.5 Inbox hub (`features/activity/` + chat entry)

- [x] **Who liked me:** Grid; **FREE** = blur + tap opens premium/subscription screen; **PREMIUM** = full.
- [x] **Visitors:** Same gating pattern.
- [x] **Matches:** Horizontal list; navigate to profile or chat.
- [x] **Messages list:** Snippet + relative time; sorted by latest activity.
- [x] **My likes** (if in scope): List/history UI wired to API.

### 2.6 Profile detail (external / shared flow)

- [x] **Hero image,** name, age, distance, bio.
- [x] **Like state:** Heart **full red** if already liked.
- [x] **Message button:** If no match and `FREE` → subscription screen; if match or premium → open chat.
- [x] **Gallery:** First media free; index 1+ blurred + paywall for free users.

### 2.7 Chat (`features/chat/`)

- [x] **Thread UI:** `ChatScreen` now renders thread list (name/avatar/snippet/date) and navigates to per-thread conversation view; `ConversationScreen` has bubble UI, timestamps, input row, and send flow.
- [x] **Attach image/video:** Camera + gallery pick flows wired in `ConversationScreen` (image/video), uploads via `POST /api/media/upload`, then sends chat message content as uploaded URL.
- [x] **Realtime or polling:** Polling implemented (thread list + active conversation periodic refresh via Riverpod invalidation timers).

### 2.8 My profile & settings (`features/profile/` + `features/premium/`)

- [x] **Header + edit profile:** Bio inline edit with save/cancel; avatar with initials; user name + email.
- [x] **Discovery settings:** Distance radius slider, age range slider, orientation preference chips — sync to `PUT /api/account/profile`.
- [x] **Theme toggle** + persist (Riverpod `themeProvider`).
- [x] **Push toggle:** Wire to OS settings / local notifications strategy.
- [ ] **Subscription:** `in_app_purchase` — purchase flow + send token to `POST /api/billing/verify`; "Go Gold" UI.
- [x] **Account:** Logout, hide account (`PATCH /api/account/hide`), delete account (`DELETE /api/account`) — all with confirmation dialogs.

### 2.9 Premium gating (cross-cutting)

- [x] **Single source of tier** in app state — premium gates now read `isPremiumProvider` (subscription-backed) instead of stale auth-only flags for Activity and Profile Detail gating.
- [x] **Reusable “locked content”** widget (blur sigma ~15) + CTA to subscription.

### 2.10 Quality

- [x] **Models:** Freezed + json_serializable generated for core DTOs.
- [ ] **Widget / integration tests** for auth, discover swipe, and paywall paths (as feasible).

---

## 3. “Done = running” smoke test

- [ ] New user can register, complete profile with one photo, grant location, appear in someone else’s discover (with two test accounts).
- [ ] Swipe like from both sides creates a **match** and shows in Inbox.
- [ ] Free user cannot message non-match; premium can (per rules).
- [ ] Free user sees blurred likes/visitors/extra media; after purchase, sees full content.
- [ ] User can hide account (disappears from discover) and delete account (data gone).
- [ ] Production deploy: Worker + Neon + R2 + Play Console products live.

---

## Legend

- Check items off in GitHub Issues or project boards by linking to this file.
- When the API path or payload changes, update **§0 API contract** and Flutter `core/constants` in the same PR.
