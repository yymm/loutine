import { zValidator } from '@hono/zod-validator';
import { createHono } from '../../utils/app_factory';
import {
	createNotesSchema,
	notesCursorSchema,
	notesIdSchema,
	notesListSchema,
	updateNotesSchema,
} from './types';
import { send_404 } from '../../utils/errors';

const app = createHono();

app.get('/', zValidator('query', notesListSchema), async (c) => {
	const { start_date, end_date } = c.req.valid('query');
	const { notesUsecase } = c.var;
	const all_notes = await notesUsecase.get_date_range(start_date, end_date);
	return c.json(all_notes, 200);
});

app.get('/latest', zValidator('query', notesCursorSchema), async (c) => {
	const { cursor, limit } = c.req.valid('query');
	const { notesUsecase } = c.var;
	const { notes, next_cursor, has_next_page } =
		await notesUsecase.get_latest_by_cursor(cursor, limit);
	return c.json({ notes, next_cursor, has_next_page }, 200);
});

app.get('/:id', zValidator('param', notesIdSchema), async (c) => {
	const { id } = c.req.valid('param');
	const { notesUsecase } = c.var;
	const note = await notesUsecase.get_by_id(id);
	if (!note) {
		return send_404(c, 'Note Not Found');
	}
	return c.json(note, 200);
});

app.post('/', zValidator('json', createNotesSchema), async (c) => {
	const { title, text, tag_ids } = c.req.valid('json');
	const { notesUsecase } = c.var;
	const new_note = await notesUsecase.create({
		title,
		text,
		tag_ids,
	});
	return c.json(new_note, 201);
});

app.put('/', zValidator('json', updateNotesSchema), async (c) => {
	const { id, title, text, tag_ids } = c.req.valid('json');
	const { notesUsecase } = c.var;
	const updated_note = await notesUsecase.update({
		id,
		title,
		text,
		tag_ids,
	});
	return c.json(updated_note, 200);
});

app.delete('/:id', zValidator('param', notesIdSchema), async (c) => {
	const { id } = c.req.valid('param');
	const { notesUsecase } = c.var;
	const deleted_note = await notesUsecase.delete(id);
	if (!deleted_note) {
		return send_404(c, 'Note Not Found');
	}
	return c.json(deleted_note, 200);
});

export { app as notes_router };
