ALTER TABLE "profile" ADD COLUMN IF NOT EXISTS "country" text;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "profile_country_idx" ON "profile" USING btree ("country");
