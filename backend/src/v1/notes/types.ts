import {z} from "zod";

export const notesListSchema = z.object({
  start_date: z.string().date(), // YYYY-MM-DD
  end_date: z.string().date(), // YYYY-MM-DD
});
