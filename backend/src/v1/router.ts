import { createHono } from '../utils/app_factory';
import { categories_router } from './categories/router';
import { links_router } from './links/router';
import { notes_router } from './notes/router';
import { purchases_router } from './purchases/router';
import { tags_router } from './tags/router';
import { url_router } from './url/router';

const v1_router = createHono().basePath('v1');

v1_router.route('/links', links_router);
v1_router.route('/purchases', purchases_router);
v1_router.route('/notes', notes_router);
v1_router.route('/tags', tags_router);
v1_router.route('/categories', categories_router);
v1_router.route('/url', url_router);

export { v1_router };
