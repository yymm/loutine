import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { drizzle } from 'drizzle-orm/d1';
import { Hono } from 'hono';
import { CategoriesUsecase } from '../v1/categories/usecase';
import { LinksUsecase } from '../v1/links/usecase';
import { NotesUsecase } from '../v1/notes/usecase';
import { PurchasesUsecase } from '../v1/purchases/usecase';
import { TagsUsecase } from '../v1/tags/usecase';
import { UrlUsecase } from '../v1/url/usecase';

export type Env = {
	Variables: {
		db: DrizzleD1Database;
		categoriesUsecase: CategoriesUsecase;
		linksUsecase: LinksUsecase;
		tagsUsecase: TagsUsecase;
		urlUsecase: UrlUsecase;
		purchasesUsecase: PurchasesUsecase;
		notesUsecase: NotesUsecase;
	};
	Bindings: {
		DB: D1Database;
		CUSTOM_AUTH_KEY?: string;
	};
};

export const createHono = () => {
	const app = new Hono<Env>();
	app.use(async (c, next) => {
		const db = drizzle(c.env.DB);
		c.set('db', db);
		// set usecases
		c.set('categoriesUsecase', new CategoriesUsecase(db));
		c.set('linksUsecase', new LinksUsecase(db));
		c.set('tagsUsecase', new TagsUsecase(db));
		c.set('urlUsecase', new UrlUsecase());
		c.set('purchasesUsecase', new PurchasesUsecase(db));
		c.set('notesUsecase', new NotesUsecase(db));
		await next();
	});
	return app;
};
