import { zValidator } from '@hono/zod-validator';
import { createHono } from '../../utils/app_factory';
import { urlTitleSchema } from './types';

const app = createHono();

// API to extract the HTML title from a URL
app.post('/title', zValidator('json', urlTitleSchema), async (c) => {
	const { url } = c.req.valid('json');
	const { urlUsecase } = c.var;
	const title = await urlUsecase.get_url_title(url);
  const ogp = await urlUsecase.get_url_ogp(url);
	return c.json({ ...ogp, title, url }, 200);
});

export { app as url_router }
