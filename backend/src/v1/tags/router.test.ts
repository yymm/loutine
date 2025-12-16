import { env } from 'cloudflare:test';
import { tags_router } from './router';
import type { Tag } from './types';

describe('tags router', () => {
	const body = {
		name: 'test tag',
		description: 'test tag description',
	};

	beforeAll(async () => {
		await tags_router.request(
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
		const res = await tags_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const tag: Tag = await res.json();
		expect(res.status).toBe(201);
		expect(tag.name).toBe(body.name);
		expect(tag.description).toBe(body.description);
	});

	it('GET /1', async () => {
		const res = await tags_router.request('/1', {}, env);
		const tag: Tag = await res.json();
		expect(res.status).toBe(200);
		expect(tag.name).toBe(body.name);
		expect(tag.description).toBe(body.description);
	});

	it('GET /', async () => {
		const res = await tags_router.request('/', {}, env);
		const tags: Array<Tag> = await res.json();
		expect(res.status).toBe(200);
		expect(tags.length).toBe(1);
	});

	it('PUT /', async () => {
		const put_body = {
			id: 1,
			name: 'updated tag test',
			description: 'updated tag description test',
		};
		const res = await tags_router.request(
			'/',
			{
				method: 'PUT',
				body: JSON.stringify(put_body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const tag: Tag = await res.json();
		expect(res.status).toBe(200);
		expect(tag.name).toBe(put_body.name);
		expect(tag.description).toBe(put_body.description);
	});
});
