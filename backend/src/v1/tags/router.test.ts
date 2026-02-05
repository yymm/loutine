import { env } from 'cloudflare:test';
import { tags_router } from './router';
import type { Tag } from './types';

describe('tags router', () => {
	const body = {
		name: 'test tag',
		description: 'test tag description',
	};
	let createdTagId: number;

	beforeEach(async () => {
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
		createdTagId = tag.id;
	});

	it('POST /', async () => {
		const newBody = {
			name: 'another tag',
			description: 'another tag description',
		};
		const res = await tags_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const tag: Tag = await res.json();
		expect(res.status).toBe(201);
		expect(tag.name).toBe(newBody.name);
		expect(tag.description).toBe(newBody.description);
	});

	it('POST / without required fields', async () => {
		const newBody = {
			description: 'no name provided',
		};
		const res = await tags_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		expect(res.status).toBe(400);
	});

	it('GET /:id', async () => {
		const res = await tags_router.request(`/${createdTagId}`, {}, env);
		const tag: Tag = await res.json();
		expect(res.status).toBe(200);
		expect(tag.name).toBe(body.name);
		expect(tag.description).toBe(body.description);
	});

	it('GET /:id mismatch param', async () => {
		const res = await tags_router.request(`/xxxx`, {}, env);
		expect(res.status).toBe(400);
	});

	it('GET /:id 404', async () => {
		const res = await tags_router.request(`/9999`, {}, env);
		expect(res.status).toBe(404);
	});

	it('GET /', async () => {
		const res = await tags_router.request('/', {}, env);
		const tags: Array<Tag> = await res.json();
		expect(res.status).toBe(200);
		expect(tags.length).toBeGreaterThanOrEqual(1);
	});

	it('PUT /', async () => {
		const put_body = {
			id: createdTagId,
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

	it('DELETE /:id', async () => {
		const res = await tags_router.request(
			`/${createdTagId}`,
			{ method: 'DELETE' },
			env,
		);
		expect(res.status).toBe(200);
	});

	it('DELETE /:id 404', async () => {
		const res = await tags_router.request(`/9999`, { method: 'DELETE' }, env);
		expect(res.status).toBe(404);
	});
});
