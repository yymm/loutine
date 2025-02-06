import { env } from 'cloudflare:test';
import { tags_router } from './router';
import type { Tag } from './types';

describe('tags router', () => {
	const body = {
		title: 'test tag',
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
		expect(tag.title).toBe(body.title);
		expect(tag.description).toBe(body.description);
	});

	it('GET /1', async () => {
		const res = await tags_router.request('/1', {}, env);
		const tag: Tag = await res.json();
		expect(res.status).toBe(200);
		expect(tag.title).toBe(body.title);
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
			title: 'updated tag test',
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
		expect(tag.title).toBe(put_body.title);
		expect(tag.description).toBe(put_body.description);
	});
});
