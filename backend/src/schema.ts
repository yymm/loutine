import { sql } from 'drizzle-orm';
import {
	index,
	integer,
	real,
	sqliteTable,
	text,
} from 'drizzle-orm/sqlite-core';

export const links = sqliteTable(
	'links',
	{
		id: integer('id').primaryKey({ autoIncrement: true }),
		title: text('title').notNull(),
		url: text('url').notNull(),
		created_at: text('created_at')
			.notNull()
			.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
		updated_at: text('updated_at')
			.notNull()
			.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`)
			.$onUpdateFn(() => sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
	},
	(table) => [index('links_created_at_idx').on(table.created_at)],
);

export const purchases = sqliteTable(
	'purchases',
	{
		id: integer('id').primaryKey({ autoIncrement: true }),
		title: text('title').notNull(),
		cost: real('cost').notNull(),
		currency_code: text('currency').default('JPY').notNull(),
		created_at: text('created_at')
			.notNull()
			.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
		updated_at: text('updated_at')
			.notNull()
			.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`)
			.$onUpdateFn(() => sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
		category_id: integer('category_id').references(() => categories.id),
	},
	(table) => [index('purchases_created_at_idx').on(table.created_at)],
);

export const notes = sqliteTable(
	'notes',
	{
		id: integer('id').primaryKey({ autoIncrement: true }),
		title: text('title').notNull(),
		text: text('text').notNull(),
		created_at: text('created_at')
			.notNull()
			.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
		updated_at: text('updated_at')
			.notNull()
			.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`)
			.$onUpdateFn(() => sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
	},
	(table) => [index('notes_created_at_idx').on(table.created_at)],
);

// 'tags' relationship between 'links', 'notes' and N:N
//
//    * ... 1
// tags-----links
//
//    * ... 1
// tags-----notes
export const tags = sqliteTable('tags', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	name: text('name').unique().notNull(),
	description: text('description'),
	created_at: text('created_at')
		.notNull()
		.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`)
		.$onUpdateFn(() => sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
});

export const link_tag = sqliteTable('link_tag', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	link_id: integer('link_id')
		.notNull()
		.references(() => links.id),
	tag_id: integer('tag_id')
		.notNull()
		.references(() => tags.id),
	created_at: text('created_at')
		.notNull()
		.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`)
		.$onUpdateFn(() => sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
});

export const note_tag = sqliteTable('note_tag', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	note_id: integer('note_id')
		.notNull()
		.references(() => notes.id),
	tag_id: integer('tag_id')
		.notNull()
		.references(() => tags.id),
	created_at: text('created_at')
		.notNull()
		.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`)
		.$onUpdateFn(() => sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
});

// 'categories' relationship 'purchases' and 1:N
//
//          1 ... 1
// categories-----purchases
export const categories = sqliteTable('categories', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	name: text('name').unique().notNull(),
	description: text('description'),
	created_at: text('created_at')
		.notNull()
		.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`)
		.$onUpdateFn(() => sql`(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))`),
});
