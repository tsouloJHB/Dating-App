ALTER TABLE "profile" ADD COLUMN "discovery_radius" integer DEFAULT 50 NOT NULL;--> statement-breakpoint
ALTER TABLE "profile" ADD COLUMN "min_age_range" integer DEFAULT 18 NOT NULL;--> statement-breakpoint
ALTER TABLE "profile" ADD COLUMN "max_age_range" integer DEFAULT 99 NOT NULL;--> statement-breakpoint
ALTER TABLE "profile" ADD COLUMN "interests" text[] DEFAULT '{}'::text[] NOT NULL;