# Environment variables

This document lists **required** and **optional** configuration for a working JustHookups stack (API Worker, Neon, Better Auth, R2, Alchemy). Validation rules live in `@JustHookUps/env` (`worker-env.ts`).

## Required (API Worker)

Used by Hono on Cloudflare Workers (`apps/server`). Same keys must exist as **Wrangler secrets / vars** in production and in **`.dev.vars`** for local `wrangler dev`.

| Variable | Purpose |
| :--- | :--- |
| `DATABASE_URL` | Neon Postgres connection string (`postgresql://…` or `postgres://…`). |
| `CORS_ORIGIN` | Allowed browser/app origin for credentialed requests (e.g. `http://localhost:3000` or your Flutter web origin). |
| `BETTER_AUTH_SECRET` | Better Auth secret; **minimum 32 characters**. |
| `BETTER_AUTH_URL` | Public base URL of the API as Better Auth sees it (e.g. `http://127.0.0.1:8787` for local Wrangler). |
| `MEDIA_BUCKET` | **Not an env string** — R2 **binding** name in Wrangler/Alchemy (`MEDIA_BUCKET`). |

## Required for Google Sign-In

If your app uses Google social sign-in (`POST /api/auth/sign-in/social` with `provider=google`), both variables must be configured in Worker runtime:

| Variable | Purpose |
| :--- | :--- |
| `GOOGLE_CLIENT_ID` | OAuth client ID used by Better Auth Google provider. |
| `GOOGLE_CLIENT_SECRET` | OAuth client secret used by Better Auth Google provider. |

**Session cookies (Better Auth):** In `packages/auth`, cookie defaults follow **`BETTER_AUTH_URL`**: **`https://`** uses `SameSite=None` and `Secure=true` (cross-site browser flows). **`http://`** (typical local Wrangler) uses `SameSite=Lax` and `Secure=false` so browsers accept cookies. Flutter/native clients should still prefer the **bearer** token (`set-auth-token` / `Authorization`).

**Optional — list thumbnails:** Set Worker var **`MEDIA_LIST_THUMB_WIDTH`** (e.g. `200`) to emit **`photoThumbUrls`** on profile payloads via Cloudflare **Image Resizing** (`/cdn-cgi/image/...`). Requires resizing enabled on your zone; see `apps/server/wrangler.toml` comment. Alchemy binds an empty default string so the key always exists.

### Where to set them

| Context | Location |
| :--- | :--- |
| Local Wrangler | `apps/server/.dev.vars` (secrets) + optional `wrangler.toml` `[vars]` for non-secret defaults |
| Local reference copy | `apps/server/.env` (used by Drizzle CLI via `packages/db/drizzle.config.ts`; keep out of git) |
| Production Worker | `wrangler secret put …` or Alchemy secret bindings |
| Validate strings only | From repo root: `pnpm env:check` (reads `apps/server/.env`) |

## Alchemy (optional path)

Only if you run `pnpm dev:alchemy` or deploy with Alchemy (`packages/alchemy`). Cloudflare’s API must be reachable.

| Variable / action | Purpose |
| :--- | :--- |
| `alchemy login` | Preferred: stores credentials for the CLI. |
| `CLOUDFLARE_API_TOKEN` | API token with permissions to manage Workers, R2, etc. |
| `CLOUDFLARE_API_KEY` + `CLOUDFLARE_EMAIL` | Alternative to token (legacy API key). |

Alchemy also injects Worker bindings (`DATABASE_URL`, `CORS_ORIGIN`, `BETTER_AUTH_*`, `MEDIA_BUCKET`) — keep those aligned with `apps/server/.env` while developing.

## Database (Drizzle + Neon)

Schema lives in `packages/db/src/schema/` (Better Auth tables in `auth.ts`, app tables in `domain.ts`). The Drizzle CLI reads connection settings from `apps/server/.env` via `packages/db/drizzle.config.ts`.

**Neon + `pnpm db:migrate`:** Pooled URLs (`…-pooler…` or `pgbouncer=true`) often cause `drizzle-kit migrate` to hang or exit with code **1** and no SQL error. Prefer Neon’s **direct** connection string: either set **`DATABASE_URL_MIGRATE`** in `apps/server/.env`, or let `drizzle.config.ts` rewrite a pooled `DATABASE_URL` when possible.

| Command (repo root) | Purpose |
| :--- | :--- |
| `pnpm db:generate` | Emit SQL + journal under `packages/db/src/migrations/` from the TypeScript schema. Run after schema changes. |
| `pnpm db:migrate` | Apply pending migrations to the database (tracked in `drizzle`’s journal). Preferred for shared environments. |
| `pnpm db:push` | Push schema directly without generating a migration file — useful for quick local experiments only. |
| `pnpm db:studio` | Open Drizzle Studio against the same `DATABASE_URL`. |

## Flutter (future / parallel)

Not validated by `pnpm env:check` today. Plan for:

| Variable | Purpose |
| :--- | :--- |
| `API_BASE_URL` (or build-time `--dart-define`) | Hono base URL, e.g. `https://api.example.com` or `http://10.0.2.2:8787` (Android emulator → host). |

Use the same `CORS_ORIGIN` on the server as the origin your app uses (web); mobile native apps often use cookie or token patterns per Better Auth setup.

## Optional (later features)

| Variable | Purpose |
| :--- | :--- |
| Google Play / Play Developer API | Server-side purchase verification (`POST /api/billing/verify`). |
| FCM / push | Server key or service account for outbound notifications (see `flutterapp.md`). |
| Cloudflare Images | Token or account details if serving variants beyond R2. |

## Quick checks

1. Copy `apps/server/.env.example` → `apps/server/.env` and fill values.
2. For Wrangler: copy the same secret values into `apps/server/.dev.vars` (Wrangler does not read `.env` for secrets by default).
3. Run `pnpm env:check`.
4. Run `pnpm dev` — the Worker calls `assertWorkerEnv` on boot; missing R2 or bad strings fail immediately with a clear error.
