import { env } from 'cloudflare:test';
import { beforeEach, describe, expect, it } from 'vitest';
import { purchases_router } from './router';

describe('purchases router', () => {
	const body = {
		title: 'test purchase',
		cost: 1000,
	};
	let _createdPurchaseId: number;

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
		_createdPurchaseId = purchase.id;
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
});
