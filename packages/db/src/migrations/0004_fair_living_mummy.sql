ALTER TABLE "profile" ADD COLUMN IF NOT EXISTS "interests" text[] DEFAULT '{}'::text[] NOT NULL;
