import { zValidator } from '@hono/zod-validator';
import { createHono } from '../../utils/app_factory';
import { createTagsSchema, tagsIdSchema, updateTagsSchema } from './types';

const app = createHono();

app.get('/', async (c) => {
	const { tagsUsecase } = c.var;
	const all_tags = await tagsUsecase.get_all();
	return c.json(all_tags, 200);
});

app.get('/:id', zValidator('param', tagsIdSchema), async (c) => {
	const { id } = c.req.valid('param');
	const { tagsUsecase } = c.var;
	const tag = await tagsUsecase.get_by_id(id);
	return c.json(tag, 200);
});

app.post('/', zValidator('json', createTagsSchema), async (c) => {
	const { name, description } = c.req.valid('json');
	const { tagsUsecase } = c.var;
	const new_tag = await tagsUsecase.create({ name, description });
	return c.json(new_tag, 201);
});

app.put('/', zValidator('json', updateTagsSchema), async (c) => {
	const { id, name, description } = c.req.valid('json');
	const { tagsUsecase } = c.var;
	const updated_tag = await tagsUsecase.update({
		id,
		name,
		description,
	});
	return c.json(updated_tag, 200);
});

app.delete('/:id', zValidator('param', tagsIdSchema), async (c) => {
	const { id } = c.req.valid('param');
	const { tagsUsecase } = c.var;
	const deleted_tag = await tagsUsecase.delete(id);
	return c.json(deleted_tag, 200);
});

export { app as tags_router };
