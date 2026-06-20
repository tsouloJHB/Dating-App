// 1. THIS MUST GO FIRST BEFORE ALL IMPORTS
process.env.ALCHEMY_CI_STATE_STORE_CHECK = "false";

import alchemy from "alchemy";
import { Worker } from "alchemy/cloudflare";
import { config } from "dotenv";
import path from "node:path"; // Added for deterministic absolute paths

// Use absolute path resolution so the build pipeline finds the files accurately
config({ path: path.resolve(process.cwd(), "./.env") });
config({ path: path.resolve(process.cwd(), "../../apps/server/.env") });

// Fallback safety check: If dotenv missed it, let's look at standard process.env 
// or feed it manually if your CI provides it under a different name
function binding(value: string | undefined, name: string): string {
    const lookup = value || process.env[name];
    if (!lookup) {
        throw new Error(`Missing Alchemy binding: ${name}`);
    }
    return lookup;
}

const app = await alchemy("JustHookUps");

const mediaBucket = {
    __brand: "R2Bucket",
    id: "media",
    name: "dating-site-media",
};
    
export const server = await Worker("server", {
    cwd: "../../apps/server",
    entrypoint: "src/index.ts",
    compatibility: "node",
    bindings: {
        // Feed the strings using our fallback binding helper
        DATABASE_URL: binding(alchemy.secret.env.DATABASE_URL, "DATABASE_URL"),
        CORS_ORIGIN: binding(alchemy.env.CORS_ORIGIN, "CORS_ORIGIN"),
        BETTER_AUTH_SECRET: binding(alchemy.secret.env.BETTER_AUTH_SECRET, "BETTER_AUTH_SECRET"),
        BETTER_AUTH_URL: binding(alchemy.env.BETTER_AUTH_URL, "BETTER_AUTH_URL"),
        
        GOOGLE_CLIENT_ID: alchemy.env.GOOGLE_CLIENT_ID ?? process.env.GOOGLE_CLIENT_ID ?? "",
        GOOGLE_CLIENT_SECRET: alchemy.env.GOOGLE_CLIENT_SECRET ?? process.env.GOOGLE_CLIENT_SECRET ?? "",
        MEDIA_BUCKET: mediaBucket,
        MEDIA_LIST_THUMB_WIDTH: "",
        GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: alchemy.secret.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON ?? process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON ?? "",
        GOOGLE_PLAY_PACKAGE_NAME: alchemy.env.GOOGLE_PLAY_PACKAGE_NAME ?? process.env.GOOGLE_PLAY_PACKAGE_NAME ?? "com.neonebula.Justhookups",
        GOOGLE_PLAY_WEBHOOK_SECRET: alchemy.secret.env.GOOGLE_PLAY_WEBHOOK_SECRET ?? process.env.GOOGLE_PLAY_WEBHOOK_SECRET ?? "",
    },
    dev: {
        port: 3000,
    },
});

console.log(`Server -> ${server.url}`);

await app.finalize();