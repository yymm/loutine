import {zValidator} from '@hono/zod-validator';
import { createHono } from '../../utils/app_factory';
import {notesListSchema} from './types';

const app = createHono();

app.get('/', zValidator('query', notesListSchema), async (c) => {
	const { start_date, end_date } = c.req.valid('query');
	const { notesUsecase } = c.var;
	const all_notes = await notesUsecase.get_date_range(start_date, end_date);
	return c.json(all_notes, 200);
});

export { app as notes_router };
