import { env } from 'cloudflare:test';
import { categories_router } from './router';
import type { Category } from './types';

describe('categories router', () => {
	const body = {
		name: 'test code',
		description: 'test code description',
	};
	let createdCategoryId: number;

	beforeEach(async () => {
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
		createdCategoryId = category.id;
	});

	it('POST /', async () => {
		const newBody = {
			name: 'another category',
			description: 'another category description',
		};
		const res = await categories_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const category: Category = await res.json();
		expect(res.status).toBe(201);
		expect(category.name).toBe(newBody.name);
		expect(category.description).toBe(newBody.description);
	});

	it('GET /:id', async () => {
		const res = await categories_router.request(
			`/${createdCategoryId}`,
			{},
			env,
		);
		const category: Category = await res.json();
		expect(res.status).toBe(200);
		expect(category.name).toBe(body.name);
		expect(category.description).toBe(body.description);
	});

	it('GET /', async () => {
		const res = await categories_router.request('/', {}, env);
		const categories: Array<Category> = await res.json();
		expect(res.status).toBe(200);
		expect(categories.length).toBeGreaterThanOrEqual(1);
	});

	it('PUT /', async () => {
		const put_body = {
			id: createdCategoryId,
			name: 'updated test',
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
		expect(category.name).toBe(put_body.name);
		expect(category.description).toBe(put_body.description);
	});

	it('DELETE /:id', async () => {
		const res = await categories_router.request(
			`/${createdCategoryId}`,
			{},
			env,
		);
		await res.json();
		expect(res.status).toBe(200);
	});
});
