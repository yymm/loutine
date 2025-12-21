import { zValidator } from '@hono/zod-validator';
import { createHono } from '../../utils/app_factory';
import { createPurchasesSchema, purchasesListSchema } from './types';

const app = createHono();

app.get('/', zValidator('query', purchasesListSchema), async (c) => {
	const { start_date, end_date } = c.req.valid('query');
	const { purchasesUsecase } = c.var;
	const all_purchases = await purchasesUsecase.get_date_range(
		start_date,
		end_date,
	);
	return c.json(all_purchases, 200);
});

app.post('/', zValidator('json', createPurchasesSchema), async (c) => {
	const { title, cost, category_id } = c.req.valid('json');
	const { purchasesUsecase } = c.var;
	const new_purchase = await purchasesUsecase.create({
		title,
		cost,
		category_id,
	});
	return c.json(new_purchase, 201);
});

export { app as purchases_router };
