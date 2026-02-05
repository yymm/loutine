import { env } from 'cloudflare:test';
import { beforeEach, describe, expect, it } from 'vitest';
import { purchases_router } from './router';
import type { Purchase } from './types';

describe('purchases router', () => {
	const body = {
		title: 'test purchase',
		cost: 1000,
	};
	let createdPurchaseId: number;

	beforeEach(async () => {
		const res = await purchases_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const purchase = (await res.json()) as { id: number };
		createdPurchaseId = purchase.id;
	});

	it('POST /', async () => {
		const newBody = {
			title: 'another purchase',
			cost: 2000,
		};
		const res = await purchases_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const purchase = (await res.json()) as { title: string; cost: number };
		expect(res.status).toBe(201);
		expect(purchase.title).toBe(newBody.title);
		expect(purchase.cost).toBe(newBody.cost);
	});

	it('POST / with category_id', async () => {
		const newBody = {
			title: 'purchase with category',
			cost: 3000,
			category_id: null,
		};
		const res = await purchases_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const purchase = (await res.json()) as { title: string; cost: number };
		expect(res.status).toBe(201);
		expect(purchase.title).toBe(newBody.title);
		expect(purchase.cost).toBe(newBody.cost);
	});

	it('GET /:id', async () => {
		const res = await purchases_router.request(
			`/${createdPurchaseId}`,
			{},
			env,
		);
		const purchase: Purchase = await res.json();
		expect(res.status).toBe(200);
		expect(purchase.title).toBe(body.title);
		expect(purchase.cost).toBe(body.cost);
	});

	it('GET / with date range', async () => {
		const res = await purchases_router.request(
			'/?start_date=2020-01-01&end_date=2099-12-31',
			{},
			env,
		);
		const purchases = await res.json();
		expect(res.status).toBe(200);
		expect(Array.isArray(purchases)).toBe(true);
	});

	it('POST / without required fields', async () => {
		const invalidBody = {
			title: 'no cost provided',
		};
		const res = await purchases_router.request(
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
		const updateBody = {
			id: createdPurchaseId,
			title: 'updated link title',
			cost: 9999,
			category_id: null,
		};
		const res = await purchases_router.request(
			`/`,
			{
				method: 'PUT',
				body: JSON.stringify(updateBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const purchase: Purchase = await res.json();
		expect(res.status).toBe(200);
		expect(purchase.title).toBe(updateBody.title);
		expect(purchase.cost).toBe(updateBody.cost);
	});

	it('PUT / without required field', async () => {
		const updateBody = {
			title: 'no id and cost provided',
		};
		const res = await purchases_router.request(
			`/`,
			{
				method: 'PUT',
				body: JSON.stringify(updateBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		expect(res.status).toBe(400);
	});

	it('DELETE /:id', async () => {
		const res = await purchases_router.request(
			`/${createdPurchaseId}`,
			{ method: 'DELETE' },
			env,
		);
		expect(res.status).toBe(200);
	});
});
