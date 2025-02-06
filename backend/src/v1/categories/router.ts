import { zValidator } from '@hono/zod-validator';
import { createHono } from '../../utils/app_factory';
import {
	categoriesIdSchema,
	createCategoriesSchema,
	updateCategoriesSchema,
} from './types';

const app = createHono();

app.get('/', async (c) => {
	const { categoriesUsecase } = c.var;
	const all_categories = await categoriesUsecase.get_all();
	return c.json(all_categories, 200);
});

app.get('/:id', zValidator('param', categoriesIdSchema), async (c) => {
	const { id } = c.req.valid('param');
	const { categoriesUsecase } = c.var;
	const category = await categoriesUsecase.get_by_id(id);
	return c.json(category, 200);
});

app.post('/', zValidator('json', createCategoriesSchema), async (c) => {
	const { name, description } = c.req.valid('json');
	const { categoriesUsecase } = c.var;
	const new_category = await categoriesUsecase.create({ name, description });
	return c.json(new_category, 201);
});

app.put('/', zValidator('json', updateCategoriesSchema), async (c) => {
	const { id, name, description } = c.req.valid('json');
	const { categoriesUsecase } = c.var;
	const updated_category = await categoriesUsecase.update({
		id,
		name,
		description,
	});
	return c.json(updated_category, 200);
});

export { app as categories_router };
