import dotenv from "dotenv";
import { defineConfig } from "drizzle-kit";

dotenv.config({
	path: "../../apps/server/.env",
});

/**
 * Drizzle Kit uses the `pg` driver.
 *
 * - Prefer `DATABASE_URL_MIGRATE` for an explicit migration connection string.
 * - Fallback to `DATABASE_URL` as-is when not provided.
 *
 * Keeping `DATABASE_URL` unchanged avoids accidental breakage when transforming
 * provider-specific URL formats.
 */
function connectionUrlForDrizzleCli(): string {
	const explicit = process.env.DATABASE_URL_MIGRATE?.trim();
	if (explicit) {
		return explicit;
	}

	const fallback = process.env.DATABASE_URL?.trim() ?? "";
	if (!fallback) {
		return "";
	}

	return fallback;
}

const dbUrl = connectionUrlForDrizzleCli();

if (!dbUrl) {
	throw new Error(
		"Drizzle CLI: set DATABASE_URL (or DATABASE_URL_MIGRATE) in apps/server/.env",
	);
}

export default defineConfig({
	schema: "./src/schema",
	out: "./src/migrations",
	dialect: "postgresql",
	dbCredentials: {
		url: dbUrl,
	},
});
