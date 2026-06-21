import { sql } from "drizzle-orm";
import type { Context } from "hono";

import { createDb } from "@JustHookUps/db";

type AuthSession = {
	user?: { id?: string };
	session?: { user?: { id?: string } };
};

/**
 * Resolve the authenticated user ID from the incoming request.
 *
 * Strategy:
 *  1. If an `Authorization: Bearer <token>` header is present, do a direct
 *     DB lookup against `session.token`.  This is the path used by Flutter
 *     mobile clients and is more reliable than an internal HTTP subrequest.
 *  2. Otherwise, fall back to a Better Auth `/api/auth/get-session` subrequest
 *     so that cookie-based web sessions still work.
 */
export async function getAuthenticatedUserId(c: Context): Promise<string | null> {
	const authHeader = c.req.header("authorization") ?? "";
	const bearer = authHeader.toLowerCase().startsWith("bearer ")
		? authHeader.slice(7).trim()
		: "";

	// ── Path 1: Bearer token — direct DB session lookup ──────────────────────
	if (bearer) {
		const db = createDb();
		const rows = await db.execute(sql`
			select user_id as "userId"
			from session
			where token = ${bearer}
				and expires_at > now()
			limit 1
		`);
		const userId = (rows.rows[0] as Record<string, unknown> | undefined)?.userId;
		if (typeof userId === "string" && userId.length > 0) {
			return userId;
		}
		// Token present but not in DB (expired or invalid) — bail out fast.
		return null;
	}

	// ── Path 2: Cookie-based session (web clients) ────────────────────────────
	const cookieHeader = c.req.header("cookie") ?? "";
	if (!cookieHeader) return null;

	const origin = new URL(c.req.url).origin;
	const authResponse = await fetch(`${origin}/api/auth/get-session`, {
		method: "GET",
		headers: {
			origin: c.req.header("origin") ?? origin,
			cookie: cookieHeader,
		},
	}).catch(() => null);

	if (!authResponse?.ok) return null;

	const rawPayload = await authResponse.json().catch(() => null);
	const authPayload =
		rawPayload && typeof rawPayload === "object"
			? (rawPayload as AuthSession)
			: null;
	const userId = authPayload?.user?.id ?? authPayload?.session?.user?.id;
	return typeof userId === "string" && userId.length > 0 ? userId : null;
}
