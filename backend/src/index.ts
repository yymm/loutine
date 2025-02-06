import { createHono } from './utils/app_factory';
import { v1_router } from './v1/router';

const app = createHono();
app.route('/api', v1_router);

export default app;
