import { createInsertSchema } from 'drizzle-zod';
import { z } from 'zod';
import { notes } from '../../schema';

export const insertNotesSchema = createInsertSchema(notes, {
	id: z.coerce.number(),
	title: z
		.string()
		.min(1, 'titleは必須です')
		.max(2048, 'titleは2048文字以内にしてください'),
	text: z
		.string()
		.min(1, 'textは必須です')
		.max(8192, 'textは8192文字以内にしてください'),
	created_at: z.string().datetime(),
	updated_at: z.string().datetime(),
});

export const createNotesSchema = insertNotesSchema
	.extend({
		tag_ids: z.coerce.number().array().nullish(),
	})
	.pick({
		title: true,
		text: true,
		tag_ids: true,
	});

export const updateNotesSchema = insertNotesSchema
	.extend({
		tag_ids: z.coerce.number().array().nullish(),
	})
	.pick({
		id: true,
		title: true,
		text: true,
		tag_ids: true,
	});

export const notesListSchema = z.object({
	start_date: z.string().date(), // YYYY-MM-DD
	end_date: z.string().date(), // YYYY-MM-DD
});

export const notesIdSchema = insertNotesSchema.pick({
	id: true,
});

export const notesCursorSchema = z.object({
	cursor: z.string().nullish(),
	limit: z.coerce.number().lte(100).default(10),
});

export type Note = z.infer<typeof insertNotesSchema>;
