import { createInsertSchema } from 'drizzle-zod';
import { z } from 'zod';
import { links } from '../../schema';

const insertLinksSchema = createInsertSchema(links, {
	id: z.coerce.number(),
	title: z
		.string()
		.min(1, 'titleは必須です')
		.max(100, 'titleは100文字以内にしてください'),
	url: z
		.string()
		.url()
		.min(1, 'urlは必須です')
		.max(1000, 'urlは100文字以内にしてください'),
	created_at: z.string().datetime(),
	updated_at: z.string().datetime(),
});

export const createLinksSchema = insertLinksSchema
	.extend({
		tag_ids: z.number().array().nullish(),
		category_id: z.number().nullish(),
	})
	.pick({
		title: true,
		url: true,
		tag_ids: true,
		category_id: true,
	});

export const updateLinksSchema = insertLinksSchema.pick({
	id: true,
	title: true,
	url: true,
});

export const linksIdSchema = insertLinksSchema.pick({
	id: true,
});

export const linksListSchema = z.object({
  start_date: z.string().date(), // YYYY-MM-DD
  end_date: z.string().date(), // YYYY-MM-DD
});
