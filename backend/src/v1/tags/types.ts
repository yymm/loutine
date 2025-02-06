import { createInsertSchema } from 'drizzle-zod';
import { z } from 'zod';
import { tags } from '../../schema';

const insertTagsSchema = createInsertSchema(tags, {
	id: z.coerce.number(),
	name: z
		.string()
		.min(1, 'nameは必須です')
		.max(100, 'nameは100文字以内にしてください'),
	description: z.string().nullable(),
	created_at: z.string().datetime(),
	updated_at: z.string().datetime(),
});

export const createTagsSchema = insertTagsSchema.pick({
	name: true,
	description: true,
});

export const updateTagsSchema = insertTagsSchema.pick({
	id: true,
	name: true,
	description: true,
});

export const tagsIdSchema = insertTagsSchema.pick({
	id: true,
});

export type Tag = z.infer<typeof insertTagsSchema>;
