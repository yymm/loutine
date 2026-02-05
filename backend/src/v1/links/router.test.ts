import { env } from 'cloudflare:test';
import { beforeEach, describe, expect, it } from 'vitest';
import { links_router } from './router';
import type { Link } from './types';
import { tags_router } from '../tags/router';
import type { Tag } from '../tags/types';

describe('links router', () => {
	const body = {
		title: 'example title',
		url: 'https://example.com',
	};
	const tag_body = {
		name: 'test tag',
		description: 'test tag description',
	};
	let created_link_id: number;
	let created_tag_id: number;

	beforeEach(async () => {
		const res = await links_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const link: Link = await res.json();
		created_link_id = link.id;
		const resTag = await tags_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(tag_body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const tag: Tag = await resTag.json();
		created_tag_id = tag.id;
	});

	it('POST /', async () => {
		const new_body = {
			title: 'another link',
			url: 'https://example.org',
		};
		const res = await links_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(new_body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const link: Link = await res.json();
		expect(res.status).toBe(201);
		expect(link.title).toBe(new_body.title);
		expect(link.url).toBe(new_body.url);
	});

	it('POST / with tag_ids', async () => {
		const new_body = {
			title: 'link with tags',
			url: 'https://example.net',
			tag_ids: [created_tag_id],
		};
		const res = await links_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(new_body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const link: Link = await res.json();
		expect(res.status).toBe(201);
		expect(link.title).toBe(new_body.title);
		expect(link.url).toBe(new_body.url);
	});

	it('GET /:id', async () => {
		const res = await links_router.request(`/${created_link_id}`, {}, env);
		const link: Link = await res.json();
		expect(res.status).toBe(200);
		expect(link.title).toBe(body.title);
		expect(link.url).toBe(body.url);
	});

	it('GET /:id mismatch param', async () => {
		const res = await links_router.request(`/xxxx`, {}, env);
		expect(res.status).toBe(400);
	});

	it('GET / with date range', async () => {
		const res = await links_router.request(
			'/?start_date=2020-01-01&end_date=2099-12-31',
			{},
			env,
		);
		const links: Array<Link> = await res.json();
		expect(res.status).toBe(200);
		expect(Array.isArray(links)).toBe(true);
	});

	it('GET / missing param', async () => {
		const res = await links_router.request('/?start_date=2020-01-01', {}, env);
		expect(res.status).toBe(400);
	});

	it('GET / mismatch param', async () => {
		const res = await links_router.request(
			'/?start_date=xxxx&end_date=xxxx',
			{},
			env,
		);
		expect(res.status).toBe(400);
	});

	it('GET /latest ', async () => {
		const res = await links_router.request('/latest?limit=5', {}, env);
		const cursor_res = (await res.json()) as {
			links: Array<Link>;
			next_cursor: string;
			has_next_page: boolean;
		};
		expect(res.status).toBe(200);
		expect(Array.isArray(cursor_res.links)).toBe(true);
	});

	it('GET /latest mismatch param', async () => {
		const res = await links_router.request('/latest?limit=xxxx', {}, env);
		expect(res.status).toBe(400);
	});

	it('POST / without required fields', async () => {
		const invalidBody = {
			title: 'no url provided',
		};
		const res = await links_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(invalidBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		expect(res.status).toBe(400);
	});

	it('PUT /', async () => {
		const update_body = {
			id: created_link_id,
			title: 'updated link title',
			url: 'https://updated.example.com',
			tag_ids: [],
		};
		const res = await links_router.request(
			`/`,
			{
				method: 'PUT',
				body: JSON.stringify(update_body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const link: Link = await res.json();
		expect(res.status).toBe(200);
		expect(link.title).toBe(update_body.title);
		expect(link.url).toBe(update_body.url);
	});

	it('PUT /', async () => {
		const update_body = {
			title: 'no id and url provided',
		};
		const res = await links_router.request(
			`/`,
			{
				method: 'PUT',
				body: JSON.stringify(update_body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		expect(res.status).toBe(400);
	});

	it('DELETE /:id', async () => {
		const res = await links_router.request(
			`/${created_link_id}`,
			{ method: 'DELETE' },
			env,
		);
		expect(res.status).toBe(200);
	});
});
