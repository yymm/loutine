import { sql } from 'drizzle-orm';
import { integer, sqliteTable, text, index } from 'drizzle-orm/sqlite-core';

export const links = sqliteTable('links', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	title: text('title').notNull(),
	url: text('url').notNull(),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
}, (table) => [
  index('links_created_at_idx').on(table.created_at),
]);

export const purchases = sqliteTable('purchases', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	title: text('title').notNull(),
	cost: integer('cost').notNull(),
	currency_code: text('currency').default('JPY').notNull(),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
}, (table) => [
  index('purchases_created_at_idx').on(table.created_at),
]);

export const notes = sqliteTable('notes', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	title: text('title').notNull(),
	text: text('text').notNull(),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
}, (table) => [
  index('notes_created_at_idx').on(table.created_at),
]);

export const tags = sqliteTable('tags', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	name: text('name').unique().notNull(),
	description: text('description'),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
});

export const link_tag = sqliteTable('link_tag', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	link_id: integer('link_id').notNull().references(() => links.id),
	tag_id: integer('tag_id').notNull().references(() => tags.id),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
});

export const purchase_tag = sqliteTable('purchase_tag', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	purchase_id: integer('purchase_id').notNull().references(() => purchases.id),
	tag_id: integer('tag_id').notNull().references(() => tags.id),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
});

export const note_tag = sqliteTable('note_tag', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	note_id: integer('note_id').notNull().references(() => notes.id),
	tag_id: integer('tag_id').notNull().references(() => tags.id),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
});

export const categories = sqliteTable('categories', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	name: text('name').unique().notNull(),
	description: text('description'),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
});

export const link_category = sqliteTable('link_category', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	link_id: integer('link_id').notNull().references(() => links.id),
	category_id: integer('category_id').notNull().references(() => categories.id),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
});

export const purchase_category = sqliteTable('purchase_category', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	purchase_id: integer('purchase_id').notNull().references(() => purchases.id),
	category_id: integer('category_id').notNull().references(() => categories.id),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
});

export const note_category = sqliteTable('note_category', {
	id: integer('id').primaryKey({ autoIncrement: true }),
	note_id: integer('note_id').notNull().references(() => notes.id),
	category_id: integer('category_id').notNull().references(() => categories.id),
	created_at: text('created_at').notNull().default(sql`(current_timestamp)`),
	updated_at: text('updated_at')
		.notNull()
		.default(sql`(current_timestamp)`)
		.$onUpdateFn(() => sql`(current_timestamp)`),
});
