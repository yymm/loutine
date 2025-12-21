import { createInsertSchema } from 'drizzle-zod';
import { z } from 'zod';
import { purchases } from '../../schema';

export const insertPurchasesSchema = createInsertSchema(purchases, {
	id: z.coerce.number(),
	title: z
		.string()
		.min(1, 'titleは必須です')
		.max(2048, 'titleは2048文字以内にしてください'),
	cost: z.number(),
	created_at: z.string().datetime(),
	updated_at: z.string().datetime(),
});

export const createPurchasesSchema = insertPurchasesSchema
	.extend({
		category_id: z.number().nullish(),
	})
	.pick({
		title: true,
		cost: true,
		category_id: true,
	});

export const purchasesListSchema = z.object({
	start_date: z.string().date(), // YYYY-MM-DD
	end_date: z.string().date(), // YYYY-MM-DD
});
