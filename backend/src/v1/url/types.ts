import { z } from 'zod';

export const urlTitleSchema = z.object({
	url: z
		.string()
		.url()
		.min(1, 'urlは必須です')
		.max(1000, 'urlは100文字以内にしてください'),
});
