import {z} from "zod";

export const purchasesListSchema = z.object({
  start_date: z.string().date(), // YYYY-MM-DD
  end_date: z.string().date(), // YYYY-MM-DD
});
