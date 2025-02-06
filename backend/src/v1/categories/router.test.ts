import { env } from 'cloudflare:test';
import { categories_router } from './router';
import type { Category } from './types';

describe('categories router', () => {
	const body = {
		title: 'test code',
		description: 'test code description',
	};

	beforeAll(async () => {
		await categories_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
	});

	it('POST /', async () => {
		const res = await categories_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const category: Category = await res.json();
		expect(res.status).toBe(201);
		expect(category.title).toBe(body.title);
		expect(category.description).toBe(body.description);
	});

	it('GET /1', async () => {
		const res = await categories_router.request('/1', {}, env);
		const category: Category = await res.json();
		expect(res.status).toBe(200);
		expect(category.title).toBe(body.title);
		expect(category.description).toBe(body.description);
	});

	it('GET /', async () => {
		const res = await categories_router.request('/', {}, env);
		const categories: Array<Category> = await res.json();
		expect(res.status).toBe(200);
		expect(categories.length).toBe(1);
	});

	it('PUT /', async () => {
		const put_body = {
			id: 1,
			title: 'updated test',
			description: 'updated description test',
		};
		const res = await categories_router.request(
			'/',
			{
				method: 'PUT',
				body: JSON.stringify(put_body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const category: Category = await res.json();
		expect(res.status).toBe(200);
		expect(category.title).toBe(put_body.title);
		expect(category.description).toBe(put_body.description);
	});
});
