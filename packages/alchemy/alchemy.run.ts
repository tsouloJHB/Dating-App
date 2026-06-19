import alchemy from "alchemy";
import { R2Bucket, Worker } from "alchemy/cloudflare";
import { config } from "dotenv";

config({ path: "./.env" });
config({ path: "../../apps/server/.env" });

function binding<T>(value: T | undefined | null, name: string): T {
	if (value === undefined || value === null) {
		throw new Error(`Missing Alchemy binding: ${name}`);
	}
	return value;
}

const app = await alchemy("JustHookUps");

const mediaBucket = await R2Bucket("media", {
	name: "justhookups-media",
});

export const server = await Worker("server", {
	cwd: "../../apps/server",
	entrypoint: "src/index.ts",
	compatibility: "node",
	bindings: {
		DATABASE_URL: binding(alchemy.secret.env.DATABASE_URL, "DATABASE_URL"),
		CORS_ORIGIN: binding(alchemy.env.CORS_ORIGIN, "CORS_ORIGIN"),
		BETTER_AUTH_SECRET: binding(
			alchemy.secret.env.BETTER_AUTH_SECRET,
			"BETTER_AUTH_SECRET",
		),
		BETTER_AUTH_URL: binding(alchemy.env.BETTER_AUTH_URL, "BETTER_AUTH_URL"),
		/** OAuth Web client ID + secret (Better Auth Google); leave empty until configured */
		GOOGLE_CLIENT_ID: alchemy.env.GOOGLE_CLIENT_ID ?? "",
		GOOGLE_CLIENT_SECRET: alchemy.env.GOOGLE_CLIENT_SECRET ?? "",
		MEDIA_BUCKET: mediaBucket,
		/** Optional; set in dashboard / vars to e.g. `200` for `/cdn-cgi/image` list thumbs */
		MEDIA_LIST_THUMB_WIDTH: "",
		/**
		 * Google Play Subscriptions (all optional — omit to use dev mode).
		 * GOOGLE_PLAY_SERVICE_ACCOUNT_JSON  – contents of the service-account key JSON file
		 * GOOGLE_PLAY_PACKAGE_NAME          – defaults to "com.neonebula.Justhookups"
		 * GOOGLE_PLAY_WEBHOOK_SECRET        – shared secret appended to the Pub/Sub push URL
		 */
		GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: alchemy.secret.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON ?? "",
		GOOGLE_PLAY_PACKAGE_NAME: alchemy.env.GOOGLE_PLAY_PACKAGE_NAME ?? "com.neonebula.Justhookups",
		GOOGLE_PLAY_WEBHOOK_SECRET: alchemy.secret.env.GOOGLE_PLAY_WEBHOOK_SECRET ?? "",
	},
	dev: {
		port: 3000,
	},
});

console.log(`Server -> ${server.url}`);

await app.finalize();
