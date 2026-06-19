import { parseLocalDevEnv } from "../packages/env/src/worker-env.ts";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { config } from "dotenv";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
config({ path: resolve(root, "apps/server/.env") });

parseLocalDevEnv(process.env);
console.log(
	"Environment OK: apps/server/.env satisfies required string variables.",
);
console.log(
	"Note: R2 MEDIA_BUCKET is only checked when the Worker runs (Wrangler / Alchemy).",
);
