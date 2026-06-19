import { env } from "@JustHookUps/env/server";
import { drizzle } from "drizzle-orm/neon-http";

import * as schema from "./schema";

export function createDb() {
	const url = env.DATABASE_URL;
	if (!url) {
		throw new Error("DATABASE_URL is required");
	}
	return drizzle(url, { schema });
}
