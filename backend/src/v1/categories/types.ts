import { createInsertSchema } from 'drizzle-zod';
import { z } from 'zod';
import { categories } from '../../schema';

const insertCategoriesSchema = createInsertSchema(categories, {
	id: z.coerce.number(),
	name: z
		.string()
		.min(1, 'nameは必須です')
		.max(100, 'nameは100文字以内にしてください'),
	description: z.string().nullable(),
	created_at: z.string().datetime(),
	updated_at: z.string().datetime(),
});

export const createCategoriesSchema = insertCategoriesSchema.pick({
	name: true,
	description: true,
});

export const updateCategoriesSchema = insertCategoriesSchema.pick({
	id: true,
	name: true,
	description: true,
});

export const categoriesIdSchema = insertCategoriesSchema.pick({
	id: true,
});

export type Category = z.infer<typeof insertCategoriesSchema>;
