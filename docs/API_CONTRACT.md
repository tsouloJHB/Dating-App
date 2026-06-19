# JustHookups — HTTP API contract

**Base URL:** configurable per environment (see Flutter `ApiConstants.baseUrl`). All app routes are prefixed with `/api` unless noted.

**Auth:** [Better Auth](https://www.better-auth.com/) is mounted at `/api/auth/*` (methods vary by route). The server enables the **bearer** plugin: native clients should send `Authorization: Bearer <token>` (token from the **`set-auth-token`** response header on sign-in/sign-up, or from the JSON `token` field when present). CORS exposes `set-auth-token` for browser-based clients.

**Conventions:**

- JSON bodies and fields use **camelCase** unless stated otherwise.
- List endpoints use **cursor pagination** where noted: request optional `cursor`, response includes `nextCursor` (opaque string or `null`) and `limit` (page size, default **8**).
- Stubs return **`501`** with `{ "ok": false }` when the handler is not implemented yet.

---

## Health

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | Plain text `OK`. |

---

## Discovery

**Canonical:** `POST /api/discover` — load a page of profiles for the current user (see AGENTS.md).

| Method | Path | Body | Response |
|--------|------|------|----------|
| `GET` | `/api/discover` | — | `{ "profiles": [], "nextCursor": null, "limit": 8 }` (empty stub; prefer `POST`). |
| `POST` | `/api/discover` | See below | `{ "profiles": ProfileCard[], "nextCursor": string \| null, "limit": number }`. |

**`POST /api/discover` JSON body** (all fields optional except where you rely on exclusion logic):

| Field | Type | Notes |
|-------|------|--------|
| `userId` | string | Actor (current user). When set, results exclude this user and users already in `interactions` for this actor. |
| `cursor` | string | Keyset cursor (last profile `id` from previous page). |
| `limit` | number | 1–8 (capped by server). |
| `latitude` | number | Reserved for distance filtering (not applied in SQL yet). |
| `longitude` | number | Reserved for distance filtering. |
| `distanceKm` | number | Reserved. |
| `minAge` | number | Reserved. |
| `maxAge` | number | Reserved. |

**`ProfileCard`** (subset of app `User` model):

`id`, `email`, `name`, `gender`, `sexualOrientation`, `age`, `latitude`, `longitude`, `photoUrls`, optional `photoThumbUrls`, `bio`, `isPremium`, `createdAt`, `updatedAt` (ISO 8601 strings).

**Premium media (server-enforced):** For **FREE** viewers, only **`photoUrls[0]`** is populated; additional slots are empty strings so gallery URLs are not leaked. **PREMIUM** viewers receive full arrays. Applies to discover, `GET /api/users/:id`, inbox, matches, and likes-out.

**List thumbnails (optional):** When the Worker env **`MEDIA_LIST_THUMB_WIDTH`** is set (e.g. `200`) and [Cloudflare Image Resizing](https://developers.cloudflare.com/images/transform-images/) is enabled on the zone, responses may include **`photoThumbUrls`** (parallel to `photoUrls`) built as `/cdn-cgi/image/width=<W>,fit=cover,format=auto/<url-encoded-full-url>`.

---

## Interactions (like / pass)

| Method | Path | Body | Response |
|--------|------|------|----------|
| `POST` | `/api/interactions` | `{ "targetUserId": string }` today; add `"type": "LIKE" \| "PASS"` when implemented. | **`501`** stub today. |
| `GET` | `/api/interactions/mine` | — | `{ "items": [], "nextCursor": null, "limit": 8 }`. |

---

## Inbox (who liked me, visitors)

| Method | Path | Response |
|--------|------|----------|
| `GET` | `/api/inbox/likes-in` | `{ "users": User[], "nextCursor": null, "limit": 8 }` |
| `GET` | `/api/inbox/visitors` | `{ "users": User[], "nextCursor": null, "limit": 8 }` |

---

## Matches

| Method | Path | Response |
|--------|------|----------|
| `GET` | `/api/matches` | `{ "matches": Match[], "nextCursor": null, "limit": 8 }` |

**`Match`:** `id`, `userId`, `matchedUserId`, `matchedAt` (ISO 8601).

---

## Messages

| Method | Path | Response / body |
|--------|------|-----------------|
| `GET` | `/api/messages/threads` | `{ "threads": MessageThread[], "nextCursor": null, "limit": 8 }` |
| `GET` | `/api/messages/:threadId` | `{ "messages": Message[], "nextCursor": null, "limit": 8 }` |
| `POST` | `/api/messages/:threadId` | Body TBD | **`501`** stub today. |

---

## Media

| Method | Path | Response |
|--------|------|----------|
| `POST` | `/api/media/upload` | Multipart `file` / `photo` / `media` → `{ ok, media: { id, url, isVideo, sortOrder } }`; row inserted with next `sort_order`. |
| `PATCH` | `/api/media/reorder` | JSON `{ "orderedIds": uuid[] }` — owned rows only; `sort_order` set to index. |
| `DELETE` | `/api/media/item/:id` | Removes R2 object (from public URL) and DB row; **404** if not owned. |
| `GET` | `/api/media/:key` | Stream object from R2 (`key` may contain `/`). |

---

## Billing

| Method | Path | Response / notes |
|--------|------|------------------|
| `GET` | `/api/billing/subscriptions` | `{ "subscription": Subscription }`; runs **expiry downgrade** (`tier_expires_at` in the past → `FREE`). `endDate` reflects premium expiry when set. |
| `POST` | `/api/billing/subscriptions` | Same handler as **`/verify`**. |
| `DELETE` | `/api/billing/subscriptions` | Sets `tier` to **FREE** and clears expiry. |
| `POST` | `/api/billing/verify` | Body: `purchaseToken`, optional `productId`, `platform`, optional **`expiresAt`** (ISO string) or **`expiresInDays`** (default **30** if both omitted). Sets **PREMIUM** + `tier_expires_at`. |

---

## Account

| Method | Path | Body / notes |
|--------|------|----------------|
| `GET` | `/api/account/profile` | App profile + prefs (`bio`, `gender`, `preferredGender`, `latitude`/`longitude`, `country`, age range, `discoveryRadius`, `interests`). |
| `PUT` / `PATCH` | `/api/account/profile` | Partial updates (Zod); same shape as GET response fields (camelCase). |
| `PATCH` | `/api/account/settings` | Alias of profile PATCH (settings = discover prefs on same row). |
| `PATCH` | `/api/account/user` | Better Auth `user` row: `name`, optional `image` (URL or `""` to clear). |
| `GET` | `/api/account/verification/status` | Manual verification placeholder status: `{ status, requestedAt, reviewedAt, reason }`. |
| `POST` | `/api/account/verification/request` | Submit verification request (moves profile to `PENDING` unless already `VERIFIED`). |
| `POST` | `/api/account/onboarding/complete` | **400** if user has zero `media` rows (min one photo). |
| `PATCH` | `/api/account/hide` | Sets `profile.is_active = false`. |
| `DELETE` | `/api/account` | Deletes auth `user` (cascades). |

`/api/account/profile` now includes verification fields:

- `verificationStatus`: `UNVERIFIED | PENDING | VERIFIED | REJECTED`
- `verificationRequestedAt`: ISO timestamp or `null`
- `verificationReviewedAt`: ISO timestamp or `null`
- `verificationReason`: string or `null`

---

## Errors

Until standardized, clients should treat:

- **`4xx` / `5xx`** — surface message or generic error.
- **`401`** — session invalid; re-auth.
- **`403`** — premium or policy gate.
- **`429`** — rate limit; backoff.

Server routes should move toward a consistent `{ "error": string, "details"?: unknown }` shape (discover already uses this for validation).

---

## Changelog

- **2026-04-05:** Initial contract; aligned list keys (`matches`, `threads`, `messages`, `users`) with Flutter parsers; documented `POST /api/discover` as canonical.
