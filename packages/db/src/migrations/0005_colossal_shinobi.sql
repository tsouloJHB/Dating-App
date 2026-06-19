DO $$ BEGIN
 CREATE TYPE "verification_status" AS ENUM('UNVERIFIED', 'PENDING', 'VERIFIED', 'REJECTED');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

ALTER TABLE "profile"
  ADD COLUMN IF NOT EXISTS "verification_status" "verification_status" DEFAULT 'UNVERIFIED' NOT NULL,
  ADD COLUMN IF NOT EXISTS "verification_requested_at" timestamp,
  ADD COLUMN IF NOT EXISTS "verification_reviewed_at" timestamp,
  ADD COLUMN IF NOT EXISTS "verification_reason" text;
