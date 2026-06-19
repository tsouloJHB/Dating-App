import { relations, sql } from "drizzle-orm";
import {
	boolean,
	index,
	integer,
	pgEnum,
	pgTable,
	primaryKey,
	real,
	text,
	timestamp,
} from "drizzle-orm/pg-core";

import { user } from "./auth";

/** Matches AGENTS.md freemium tiers. */
export const userTierEnum = pgEnum("user_tier", ["FREE", "PREMIUM"]);

/** LIKE = right swipe; PASS = X / left swipe (AGENTS: type LIKE/X). */
export const interactionTypeEnum = pgEnum("interaction_type", ["LIKE", "PASS"]);
export const verificationStatusEnum = pgEnum("verification_status", [
	"UNVERIFIED",
	"PENDING",
	"VERIFIED",
	"REJECTED",
]);

/**
 * App profile and discover fields. Auth identity lives in `user` (Better Auth).
 * AGENTS: Users — tier, gender, preference, location, is_active.
 */
export const profile = pgTable(
	"profile",
	{
		userId: text("user_id")
			.primaryKey()
			.references(() => user.id, { onDelete: "cascade" }),
		tier: userTierEnum("tier").default("FREE").notNull(),
		/** When set and in the past, tier should be treated as FREE (see `expirePremiumIfNeeded`). */
		tierExpiresAt: timestamp("tier_expires_at"),
		gender: text("gender"),
		preference: text("preference"),
		locationLat: real("location_lat"),
		locationLng: real("location_lng"),
		/**
		 * ISO 3166-1 alpha-2 country code (e.g. "ZA", "US", "GB").
		 * Auto-populated from Cloudflare `cf-ipcountry` header on profile writes.
		 * Used for region isolation in discover to show only in-country profiles.
		 */
		country: text("country"),
		/** Discovery radius in km. Used to filter discover feed. Default 50 km. */
		discoveryRadius: integer("discovery_radius").default(50).notNull(),
		/** Minimum age preference for discover feed. Default 18. */
		minAgeRange: integer("min_age_range").default(18).notNull(),
		/** Maximum age preference for discover feed. Default 99. */
		maxAgeRange: integer("max_age_range").default(99).notNull(),
		bio: text("bio"),
		/** Interest tags for profile / discover (stored as Postgres `text[]`). */
		interests: text("interests")
			.array()
			.notNull()
			.default(sql`'{}'::text[]`),
		isActive: boolean("is_active").default(true).notNull(),
		verificationStatus: verificationStatusEnum("verification_status")
			.default("UNVERIFIED")
			.notNull(),
		verificationRequestedAt: timestamp("verification_requested_at"),
		verificationReviewedAt: timestamp("verification_reviewed_at"),
		verificationReason: text("verification_reason"),
		/** Latest Google Play purchase token — stored on first verified purchase; used for RTDN webhook lookup. */
		googlePlayPurchaseToken: text("google_play_purchase_token"),
	},
	(t) => [
		index("profile_is_active_idx").on(t.isActive),
		index("profile_country_idx").on(t.country),
	],
);

export const interactions = pgTable(
	"interactions",
	{
		actorId: text("actor_id")
			.notNull()
			.references(() => user.id, { onDelete: "cascade" }),
		targetId: text("target_id")
			.notNull()
			.references(() => user.id, { onDelete: "cascade" }),
		type: interactionTypeEnum("type").notNull(),
		timestamp: timestamp("timestamp").defaultNow().notNull(),
	},
	(t) => [
		primaryKey({ columns: [t.actorId, t.targetId] }),
		index("interactions_actor_idx").on(t.actorId),
		index("interactions_target_idx").on(t.targetId),
	],
);

/**
 * Mutual likes. Store with `user_1` < `user_2` lexicographically for a stable pair key.
 */
export const matches = pgTable(
	"matches",
	{
		user1: text("user_1")
			.notNull()
			.references(() => user.id, { onDelete: "cascade" }),
		user2: text("user_2")
			.notNull()
			.references(() => user.id, { onDelete: "cascade" }),
		createdAt: timestamp("created_at").defaultNow().notNull(),
	},
	(t) => [primaryKey({ columns: [t.user1, t.user2] })],
);

export const media = pgTable(
	"media",
	{
		id: text("id").primaryKey(),
		userId: text("user_id")
			.notNull()
			.references(() => user.id, { onDelete: "cascade" }),
		url: text("url").notNull(),
		isVideo: boolean("is_video").default(false).notNull(),
		sortOrder: integer("sort_order").default(0).notNull(),
	},
	(t) => [index("media_user_sort_idx").on(t.userId, t.sortOrder)],
);

export const messages = pgTable(
	"messages",
	{
		id: text("id").primaryKey(),
		senderId: text("sender_id")
			.notNull()
			.references(() => user.id, { onDelete: "cascade" }),
		recipientId: text("recipient_id")
			.notNull()
			.references(() => user.id, { onDelete: "cascade" }),
		content: text("content").notNull(),
		timestamp: timestamp("timestamp").defaultNow().notNull(),
	},
	(t) => [
		index("messages_recipient_ts_idx").on(t.recipientId, t.timestamp),
		index("messages_sender_ts_idx").on(t.senderId, t.timestamp),
	],
);

/** Profile visitors (S2: Activity Hub). */
export const profileViews = pgTable(
	"profile_views",
	{
		id: text("id").primaryKey(),
		viewerId: text("viewer_id")
			.notNull()
			.references(() => user.id, { onDelete: "cascade" }),
		profileUserId: text("profile_user_id")
			.notNull()
			.references(() => user.id, { onDelete: "cascade" }),
		viewedAt: timestamp("viewed_at").defaultNow().notNull(),
	},
	(t) => [
		index("profile_views_profile_ts_idx").on(t.profileUserId, t.viewedAt),
	],
);

export const profileRelations = relations(profile, ({ one }) => ({
	user: one(user, { fields: [profile.userId], references: [user.id] }),
}));

export const interactionsRelations = relations(interactions, ({ one }) => ({
	actor: one(user, { fields: [interactions.actorId], references: [user.id] }),
	target: one(user, { fields: [interactions.targetId], references: [user.id] }),
}));
