import { env } from 'cloudflare:test';
import { beforeEach, describe, expect, it } from 'vitest';
import { links_router } from './router';
import type { Link } from './types';

describe('links router', () => {
	const body = {
		title: 'example title',
		url: 'https://example.com',
	};
	let createdLinkId: number;

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
		createdLinkId = link.id;
	});

	it('POST /', async () => {
		const newBody = {
			title: 'another link',
			url: 'https://example.org',
		};
		const res = await links_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const link: Link = await res.json();
		expect(res.status).toBe(201);
		expect(link.title).toBe(newBody.title);
		expect(link.url).toBe(newBody.url);
	});

	it('POST / with tag_ids', async () => {
		const newBody = {
			title: 'link with tags',
			url: 'https://example.net',
			tag_ids: [],
		};
		const res = await links_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const link: Link = await res.json();
		expect(res.status).toBe(201);
		expect(link.title).toBe(newBody.title);
		expect(link.url).toBe(newBody.url);
	});

	it('GET /:id', async () => {
		const res = await links_router.request(`/${createdLinkId}`, {}, env);
		const link: Link = await res.json();
		expect(res.status).toBe(200);
		expect(link.title).toBe(body.title);
		expect(link.url).toBe(body.url);
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

	it('PUT /:id', async () => {
		const updateBody = {
			id: createdLinkId,
			title: 'updated link title',
			url: 'https://updated.example.com',
		};
		const res = await links_router.request(
			`/${createdLinkId}`,
			{
				method: 'PUT',
				body: JSON.stringify(updateBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const link: Link = await res.json();
		expect(res.status).toBe(200);
		expect(link.title).toBe(updateBody.title);
		expect(link.url).toBe(updateBody.url);
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
});
