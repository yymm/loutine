import { createInsertSchema } from 'drizzle-zod';
import { z } from 'zod';
import { links } from '../../schema';

const insertLinksSchema = createInsertSchema(links, {
	id: z.coerce.number(),
	title: z
		.string()
		.min(1, 'titleは必須です')
		.max(2048, 'titleは2048文字以内にしてください'),
	url: z
		.string()
		.url()
		.min(1, 'urlは必須です')
		.max(4096, 'urlは4096文字以内にしてください'),
	created_at: z.string().datetime(),
	updated_at: z.string().datetime(),
});

export const createLinksSchema = insertLinksSchema
	.extend({
		tag_ids: z.number().array().nullish(),
	})
	.pick({
		title: true,
		url: true,
		tag_ids: true,
	});

export const updateLinksSchema = insertLinksSchema
	.extend({
		tag_ids: z.number().array().nullish(),
	})
	.pick({
		id: true,
		title: true,
		url: true,
		tag_ids: true,
	});

export const linksIdSchema = insertLinksSchema.pick({
	id: true,
});

export const linksListSchema = z.object({
	start_date: z.string().date(), // YYYY-MM-DD
	end_date: z.string().date(), // YYYY-MM-DD
});

export const linksCursorSchema = z.object({
	cursor: z.string().nullish(),
	limit: z.coerce.number().lte(100).default(10),
});

export type Link = z.infer<typeof insertLinksSchema>;
