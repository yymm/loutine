import { createHono } from '../../utils/app_factory';
import {purchasesListSchema} from './types';
import {zValidator} from '@hono/zod-validator';

const app = createHono();

app.get('/', zValidator('query', purchasesListSchema), async (c) => {
	const { start_date, end_date } = c.req.valid('query');
	const { purchasesUsecase } = c.var;
	const all_purchases = await purchasesUsecase.get_date_range(start_date, end_date);
	return c.json(all_purchases, 200);
});

export { app as purchases_router };
