import { zValidator } from '@hono/zod-validator';
import { createHono } from '../../utils/app_factory';
import {
	createPurchasesSchema,
	purchasesIdSchema,
	purchasesListSchema,
	updatePurchasesSchema,
} from './types';
import { send_404 } from '../../utils/errors';

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

app.get('/:id', zValidator('param', purchasesIdSchema), async (c) => {
	const { id } = c.req.valid('param');
	const { purchasesUsecase } = c.var;
	const purchase = await purchasesUsecase.get_by_id(id);
	if (!purchase) {
		return send_404(c, 'Purchase Not Found');
	}
	return c.json(purchase, 200);
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

app.put('/', zValidator('json', updatePurchasesSchema), async (c) => {
	const { id, title, cost, category_id } = c.req.valid('json');
	const { purchasesUsecase } = c.var;
	const updated_purchase = await purchasesUsecase.update({
		id,
		title,
		cost,
		category_id,
	});
	return c.json(updated_purchase, 200);
});

app.delete('/:id', zValidator('param', purchasesIdSchema), async (c) => {
	const { id } = c.req.valid('param');
	const { purchasesUsecase } = c.var;
	const deleted_purchase = await purchasesUsecase.delete(id);
	if (!deleted_purchase) {
		return send_404(c, 'Purchase Not Found');
	}
	return c.json(deleted_purchase, 200);
});

export { app as purchases_router };
