import { z } from "zod";

const postgresConnectionString = z
	.string()
	.min(1)
	.refine(
		(s) => s.startsWith("postgres://") || s.startsWith("postgresql://"),
		"Must start with postgres:// or postgresql://",
	);

/**
 * String bindings required for the API Worker (Wrangler / Alchemy).
 * R2 `MEDIA_BUCKET` is validated separately at runtime (object binding).
 */
export const workerEnvStringsSchema = z.object({
	DATABASE_URL: postgresConnectionString,
	CORS_ORIGIN: z.string().min(1),
	BETTER_AUTH_SECRET: z
		.string()
		.min(32, "Use at least 32 characters (e.g. openssl rand -hex 32)"),
	BETTER_AUTH_URL: z.string().url(),
});

export type WorkerEnvStrings = z.infer<typeof workerEnvStringsSchema>;

function isR2Binding(value: unknown): boolean {
	return (
		typeof value === "object" &&
		value !== null &&
		"put" in value &&
		typeof (value as { put: unknown }).put === "function"
	);
}

/** Call once when the Worker module loads (fails fast on misconfiguration). */
export function assertWorkerEnv(env: {
	DATABASE_URL?: unknown;
	CORS_ORIGIN?: unknown;
	BETTER_AUTH_SECRET?: unknown;
	BETTER_AUTH_URL?: unknown;
	MEDIA_BUCKET?: unknown;
}): void {
	workerEnvStringsSchema.parse({
		DATABASE_URL: env.DATABASE_URL,
		CORS_ORIGIN: env.CORS_ORIGIN,
		BETTER_AUTH_SECRET: env.BETTER_AUTH_SECRET,
		BETTER_AUTH_URL: env.BETTER_AUTH_URL,
	});
	if (!isR2Binding(env.MEDIA_BUCKET)) {
		throw new Error(
			"MEDIA_BUCKET R2 binding is missing. For Wrangler: define [[r2_buckets]] in wrangler.toml and use .dev.vars for secrets.",
		);
	}
}

/** Validates the same string vars from `process.env` (Drizzle CLI, local scripts, CI). */
export function parseLocalDevEnv(
	processEnv: NodeJS.ProcessEnv,
): WorkerEnvStrings {
	return workerEnvStringsSchema.parse({
		DATABASE_URL: processEnv.DATABASE_URL,
		CORS_ORIGIN: processEnv.CORS_ORIGIN,
		BETTER_AUTH_SECRET: processEnv.BETTER_AUTH_SECRET,
		BETTER_AUTH_URL: processEnv.BETTER_AUTH_URL,
	});
}
