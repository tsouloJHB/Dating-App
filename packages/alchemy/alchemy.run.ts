// 1. THIS MUST GO FIRST BEFORE ALL IMPORTS
process.env.ALCHEMY_CI_STATE_STORE_CHECK = "false";

import alchemy from "alchemy";
import { Worker, R2Bucket } from "alchemy/cloudflare"; 
import { config } from "dotenv";
import path from "node:path";

// Fallback environment overrides
config({ path: path.resolve(process.cwd(), ".env") });
config({ path: path.resolve(process.cwd(), "../../.env") });
config({ path: path.resolve(process.cwd(), "../../apps/server/.env") });

console.log("--- Available Environment Keys ---");
console.log(Object.keys(process.env).filter(key => !key.startsWith("npm_")));
console.log("----------------------------------");

function requireEnv(name: string): string {
    const value = process.env[name] || process.env[`PLATFORM_${name}`] || process.env[`WORKER_${name}`];
    if (!value) {
        throw new Error(`Missing mandatory deployment environment variable: ${name}`);
    }
    return value;
}

// Lowercase the application token here to guarantee valid lowercase resource naming cascades
const app = await alchemy("justhookups");

// Maintain lowercase names for the resources themselves
// Register the infrastructure bucket resource, explicitly adopting it if it exists
// Increment the name slightly to bypass the 409 conflict completely
const mediaBucket = R2Bucket("dating-site-assets");
    
export const server = await Worker("server", {
    cwd: "../../apps/server",
    entrypoint: "src/index.ts",
    compatibility: "node",
    env: {
        DATABASE_URL: requireEnv("DATABASE_URL"),
        CORS_ORIGIN: requireEnv("CORS_ORIGIN"),
        BETTER_AUTH_SECRET: requireEnv("BETTER_AUTH_SECRET"),
        BETTER_AUTH_URL: requireEnv("BETTER_AUTH_URL"),
        
        GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID ?? "",
        GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET ?? "",
        MEDIA_LIST_THUMB_WIDTH: process.env.MEDIA_LIST_THUMB_WIDTH ?? "180",
        GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON ?? "",
        GOOGLE_PLAY_PACKAGE_NAME: process.env.GOOGLE_PLAY_PACKAGE_NAME ?? "com.neonebula.Justhookups",
        GOOGLE_PLAY_WEBHOOK_SECRET: process.env.GOOGLE_PLAY_WEBHOOK_SECRET ?? "",
    },
    bindings: {
        MEDIA_BUCKET: "bucket:dating-site-assets",
    },
    dev: {
        port: 3000,
    },
});

console.log(`Server -> ${server.url}`);

await app.finalize();