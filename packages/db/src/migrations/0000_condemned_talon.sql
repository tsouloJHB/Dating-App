CREATE TYPE "public"."interaction_type" AS ENUM('LIKE', 'PASS');--> statement-breakpoint
CREATE TYPE "public"."user_tier" AS ENUM('FREE', 'PREMIUM');--> statement-breakpoint
CREATE TABLE "account" (
	"id" text PRIMARY KEY NOT NULL,
	"account_id" text NOT NULL,
	"provider_id" text NOT NULL,
	"user_id" text NOT NULL,
	"access_token" text,
	"refresh_token" text,
	"id_token" text,
	"access_token_expires_at" timestamp,
	"refresh_token_expires_at" timestamp,
	"scope" text,
	"password" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "session" (
	"id" text PRIMARY KEY NOT NULL,
	"expires_at" timestamp NOT NULL,
	"token" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp NOT NULL,
	"ip_address" text,
	"user_agent" text,
	"user_id" text NOT NULL,
	CONSTRAINT "session_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE "user" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"email_verified" boolean DEFAULT false NOT NULL,
	"image" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "user_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "verification" (
	"id" text PRIMARY KEY NOT NULL,
	"identifier" text NOT NULL,
	"value" text NOT NULL,
	"expires_at" timestamp NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "interactions" (
	"actor_id" text NOT NULL,
	"target_id" text NOT NULL,
	"type" "interaction_type" NOT NULL,
	"timestamp" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "interactions_actor_id_target_id_pk" PRIMARY KEY("actor_id","target_id")
);
--> statement-breakpoint
CREATE TABLE "matches" (
	"user_1" text NOT NULL,
	"user_2" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "matches_user_1_user_2_pk" PRIMARY KEY("user_1","user_2")
);
--> statement-breakpoint
CREATE TABLE "media" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"url" text NOT NULL,
	"is_video" boolean DEFAULT false NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "messages" (
	"id" text PRIMARY KEY NOT NULL,
	"sender_id" text NOT NULL,
	"recipient_id" text NOT NULL,
	"content" text NOT NULL,
	"timestamp" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "profile" (
	"user_id" text PRIMARY KEY NOT NULL,
	"tier" "user_tier" DEFAULT 'FREE' NOT NULL,
	"gender" text,
	"preference" text,
	"location_lat" real,
	"location_lng" real,
	"bio" text,
	"is_active" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE "profile_views" (
	"id" text PRIMARY KEY NOT NULL,
	"viewer_id" text NOT NULL,
	"profile_user_id" text NOT NULL,
	"viewed_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "account" ADD CONSTRAINT "account_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "session" ADD CONSTRAINT "session_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "interactions" ADD CONSTRAINT "interactions_actor_id_user_id_fk" FOREIGN KEY ("actor_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "interactions" ADD CONSTRAINT "interactions_target_id_user_id_fk" FOREIGN KEY ("target_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "matches" ADD CONSTRAINT "matches_user_1_user_id_fk" FOREIGN KEY ("user_1") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "matches" ADD CONSTRAINT "matches_user_2_user_id_fk" FOREIGN KEY ("user_2") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "media" ADD CONSTRAINT "media_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_sender_id_user_id_fk" FOREIGN KEY ("sender_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_recipient_id_user_id_fk" FOREIGN KEY ("recipient_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "profile" ADD CONSTRAINT "profile_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "profile_views" ADD CONSTRAINT "profile_views_viewer_id_user_id_fk" FOREIGN KEY ("viewer_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "profile_views" ADD CONSTRAINT "profile_views_profile_user_id_user_id_fk" FOREIGN KEY ("profile_user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "account_userId_idx" ON "account" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "session_userId_idx" ON "session" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "verification_identifier_idx" ON "verification" USING btree ("identifier");--> statement-breakpoint
CREATE INDEX "interactions_actor_idx" ON "interactions" USING btree ("actor_id");--> statement-breakpoint
CREATE INDEX "interactions_target_idx" ON "interactions" USING btree ("target_id");--> statement-breakpoint
CREATE INDEX "media_user_sort_idx" ON "media" USING btree ("user_id","sort_order");--> statement-breakpoint
CREATE INDEX "messages_recipient_ts_idx" ON "messages" USING btree ("recipient_id","timestamp");--> statement-breakpoint
CREATE INDEX "messages_sender_ts_idx" ON "messages" USING btree ("sender_id","timestamp");--> statement-breakpoint
CREATE INDEX "profile_is_active_idx" ON "profile" USING btree ("is_active");--> statement-breakpoint
CREATE INDEX "profile_views_profile_ts_idx" ON "profile_views" USING btree ("profile_user_id","viewed_at");