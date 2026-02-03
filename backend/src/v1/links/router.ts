import { zValidator } from '@hono/zod-validator';
import { createHono } from '../../utils/app_factory';
import {
	createLinksSchema,
	linksIdSchema,
	linksListSchema,
	updateLinksSchema,
} from './types';

const app = createHono();

app.get('/', zValidator('query', linksListSchema), async (c) => {
	const { start_date, end_date } = c.req.valid('query');
	const { linksUsecase } = c.var;
	const all_links = await linksUsecase.get_date_range(start_date, end_date);
	return c.json(all_links, 200);
});

app.get('/:id', zValidator('param', linksIdSchema), async (c) => {
	const { id } = c.req.valid('param');
	const { linksUsecase } = c.var;
	const link = await linksUsecase.get_by_id(id);
	return c.json(link, 200);
});

app.post('/', zValidator('json', createLinksSchema), async (c) => {
	const { title, url, tag_ids } = c.req.valid('json');
	const { linksUsecase } = c.var;
	const new_link = await linksUsecase.create({
		title,
		url,
		tag_ids,
	});
	return c.json(new_link, 201);
});

app.put('/:id', zValidator('json', updateLinksSchema), async (c) => {
	const { id, title, url } = c.req.valid('json');
	const { linksUsecase } = c.var;
	const updated_link = await linksUsecase.update({ id, title, url });
	return c.json(updated_link, 200);
});

app.get('/:id', zValidator('param', linksIdSchema), async (c) => {
	const { id } = c.req.valid('param');
	const { linksUsecase } = c.var;
	const link = await linksUsecase.delete(id);
	return c.json(link, 200);
});

export { app as links_router };
