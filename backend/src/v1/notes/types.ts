import {createInsertSchema} from "drizzle-zod";
import {z} from "zod";
import {notes} from "../../schema";

export const insertNotesSchema = createInsertSchema(notes, {
	id: z.coerce.number(),
	title: z
		.string()
		.min(1, 'titleは必須です')
		.max(2048, 'titleは2048文字以内にしてください'),
	text: z
		.string()
		.url()
		.min(1, 'textは必須です')
		.max(8192, 'urlは8192文字以内にしてください'),
	created_at: z.string().datetime(),
	updated_at: z.string().datetime(),
});

export const createNotesSchema = insertNotesSchema
	.extend({
		tag_ids: z.number().array().nullish(),
	})
  .pick({
    title: true,
    text: true,
    tag_ids: true,
  });

export const notesListSchema = z.object({
  start_date: z.string().date(), // YYYY-MM-DD
  end_date: z.string().date(), // YYYY-MM-DD
});
