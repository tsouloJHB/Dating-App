import { createDb } from "@JustHookUps/db";
import * as schema from "@JustHookUps/db/schema/auth";
import { env } from "@JustHookUps/env/server";
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { bearer } from "better-auth/plugins";

function sessionCookieAttributes() {
	const base = new URL(env.BETTER_AUTH_URL);
	const isHttps = base.protocol === "https:";
	// Production (HTTPS): cross-site credentialed clients need SameSite=None + Secure.
	// Local Wrangler / http://127.0.0.1 — use Lax + !Secure so browser cookies still work.
	return {
		sameSite: (isHttps ? "none" : "lax") as "none" | "lax",
		secure: isHttps,
		httpOnly: true,
	} as const;
}

export function createAuth() {
	const db = createDb();

	const explicitTrusted = env.CORS_ORIGIN.split(",")
		.map((s) => s.trim())
		.filter(Boolean);
	// Local Wrangler uses http:// for BETTER_AUTH_URL; Flutter web picks a random port each run.
	// Better Auth supports glob origins — see matchesOriginPattern in better-auth.
	const loopbackWildcards = env.BETTER_AUTH_URL.startsWith("http://")
		? (["http://localhost:*", "http://127.0.0.1:*"] as const)
		: [];

	const workerEnv = env as typeof env & {
		GOOGLE_CLIENT_ID?: string;
		GOOGLE_CLIENT_SECRET?: string;
	};
	const googleClientId = workerEnv.GOOGLE_CLIENT_ID?.trim() ?? "";
	const googleClientSecret = workerEnv.GOOGLE_CLIENT_SECRET?.trim() ?? "";
	if ((googleClientId.length > 0) !== (googleClientSecret.length > 0)) {
		throw new Error(
			"Google OAuth is misconfigured: set both GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET, or leave both unset.",
		);
	}
	const googleOAuth =
		googleClientId.length > 0 && googleClientSecret.length > 0
			? {
					google: {
						clientId: googleClientId,
						clientSecret: googleClientSecret,
					},
				}
			: undefined;

	return betterAuth({
		database: drizzleAdapter(db, {
			provider: "pg",

			schema: schema,
		}),
		plugins: [bearer()],
		trustedOrigins: [...explicitTrusted, ...loopbackWildcards],
		...(googleOAuth ? { socialProviders: googleOAuth } : {}),
		emailAndPassword: {
			enabled: true,
		},
		// uncomment cookieCache setting when ready to deploy to Cloudflare using *.workers.dev domains
		// session: {
		//   cookieCache: {
		//     enabled: true,
		//     maxAge: 60,
		//   },
		// },
		session: {
			expiresIn: 60 * 60 * 24 * 30,       // 30-day session lifetime
			updateAge: 60 * 60 * 24,             // extend when active in the last 24 h
		},
		secret: env.BETTER_AUTH_SECRET,
		baseURL: env.BETTER_AUTH_URL,
		advanced: {
			defaultCookieAttributes: sessionCookieAttributes(),
			// uncomment crossSubDomainCookies setting when ready to deploy and replace <your-workers-subdomain> with your actual workers subdomain
			// https://developers.cloudflare.com/workers/wrangler/configuration/#workersdev
			// crossSubDomainCookies: {
			//   enabled: true,
			//   domain: "<your-workers-subdomain>",
			// },
		},
	});
}
