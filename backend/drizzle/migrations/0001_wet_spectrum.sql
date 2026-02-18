PRAGMA foreign_keys=OFF;--> statement-breakpoint
CREATE TABLE `__new_categories` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`name` text NOT NULL,
	`description` text,
	`created_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	`updated_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL
);
--> statement-breakpoint
INSERT INTO `__new_categories`("id", "name", "description", "created_at", "updated_at") 
SELECT "id", "name", "description", 
  strftime('%Y-%m-%dT%H:%M:%SZ', "created_at"), 
  strftime('%Y-%m-%dT%H:%M:%SZ', "updated_at") 
FROM `categories`;--> statement-breakpoint
DROP TABLE `categories`;--> statement-breakpoint
ALTER TABLE `__new_categories` RENAME TO `categories`;--> statement-breakpoint
PRAGMA foreign_keys=ON;--> statement-breakpoint
CREATE UNIQUE INDEX `categories_name_unique` ON `categories` (`name`);--> statement-breakpoint
CREATE TABLE `__new_link_tag` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`link_id` integer NOT NULL,
	`tag_id` integer NOT NULL,
	`created_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	`updated_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	FOREIGN KEY (`link_id`) REFERENCES `links`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`tag_id`) REFERENCES `tags`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
INSERT INTO `__new_link_tag`("id", "link_id", "tag_id", "created_at", "updated_at") 
SELECT "id", "link_id", "tag_id", 
  strftime('%Y-%m-%dT%H:%M:%SZ', "created_at"), 
  strftime('%Y-%m-%dT%H:%M:%SZ', "updated_at") 
FROM `link_tag`;--> statement-breakpoint
DROP TABLE `link_tag`;--> statement-breakpoint
ALTER TABLE `__new_link_tag` RENAME TO `link_tag`;--> statement-breakpoint
CREATE TABLE `__new_links` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`title` text NOT NULL,
	`url` text NOT NULL,
	`created_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	`updated_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL
);
--> statement-breakpoint
INSERT INTO `__new_links`("id", "title", "url", "created_at", "updated_at") 
SELECT "id", "title", "url", 
  strftime('%Y-%m-%dT%H:%M:%SZ', "created_at"), 
  strftime('%Y-%m-%dT%H:%M:%SZ', "updated_at") 
FROM `links`;--> statement-breakpoint
DROP TABLE `links`;--> statement-breakpoint
ALTER TABLE `__new_links` RENAME TO `links`;--> statement-breakpoint
CREATE INDEX `links_created_at_idx` ON `links` (`created_at`);--> statement-breakpoint
CREATE TABLE `__new_note_tag` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`note_id` integer NOT NULL,
	`tag_id` integer NOT NULL,
	`created_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	`updated_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	FOREIGN KEY (`note_id`) REFERENCES `notes`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`tag_id`) REFERENCES `tags`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
INSERT INTO `__new_note_tag`("id", "note_id", "tag_id", "created_at", "updated_at") 
SELECT "id", "note_id", "tag_id", 
  strftime('%Y-%m-%dT%H:%M:%SZ', "created_at"), 
  strftime('%Y-%m-%dT%H:%M:%SZ', "updated_at") 
FROM `note_tag`;--> statement-breakpoint
DROP TABLE `note_tag`;--> statement-breakpoint
ALTER TABLE `__new_note_tag` RENAME TO `note_tag`;--> statement-breakpoint
CREATE TABLE `__new_notes` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`title` text NOT NULL,
	`text` text NOT NULL,
	`created_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	`updated_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL
);
--> statement-breakpoint
INSERT INTO `__new_notes`("id", "title", "text", "created_at", "updated_at") 
SELECT "id", "title", "text", 
  strftime('%Y-%m-%dT%H:%M:%SZ', "created_at"), 
  strftime('%Y-%m-%dT%H:%M:%SZ', "updated_at") 
FROM `notes`;--> statement-breakpoint
DROP TABLE `notes`;--> statement-breakpoint
ALTER TABLE `__new_notes` RENAME TO `notes`;--> statement-breakpoint
CREATE INDEX `notes_created_at_idx` ON `notes` (`created_at`);--> statement-breakpoint
CREATE TABLE `__new_purchases` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`title` text NOT NULL,
	`cost` real NOT NULL,
	`currency` text DEFAULT 'JPY' NOT NULL,
	`created_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	`updated_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	`category_id` integer,
	FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
INSERT INTO `__new_purchases`("id", "title", "cost", "currency", "created_at", "updated_at", "category_id") 
SELECT "id", "title", "cost", "currency", 
  strftime('%Y-%m-%dT%H:%M:%SZ', "created_at"), 
  strftime('%Y-%m-%dT%H:%M:%SZ', "updated_at"), 
  "category_id" 
FROM `purchases`;--> statement-breakpoint
DROP TABLE `purchases`;--> statement-breakpoint
ALTER TABLE `__new_purchases` RENAME TO `purchases`;--> statement-breakpoint
CREATE INDEX `purchases_created_at_idx` ON `purchases` (`created_at`);--> statement-breakpoint
CREATE TABLE `__new_tags` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`name` text NOT NULL,
	`description` text,
	`created_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL,
	`updated_at` text DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')) NOT NULL
);
--> statement-breakpoint
INSERT INTO `__new_tags`("id", "name", "description", "created_at", "updated_at") 
SELECT "id", "name", "description", 
  strftime('%Y-%m-%dT%H:%M:%SZ', "created_at"), 
  strftime('%Y-%m-%dT%H:%M:%SZ', "updated_at") 
FROM `tags`;--> statement-breakpoint
DROP TABLE `tags`;--> statement-breakpoint
ALTER TABLE `__new_tags` RENAME TO `tags`;--> statement-breakpoint
CREATE UNIQUE INDEX `tags_name_unique` ON `tags` (`name`);