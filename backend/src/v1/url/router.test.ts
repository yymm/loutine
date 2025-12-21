import { env } from 'cloudflare:test';
import { describe, expect, it } from 'vitest';
import { url_router } from './router';

describe('url router', () => {
	it('POST /title', async () => {
		const body = {
			url: 'https://dev.to/abdullahyasir/flutter-development-setup-for-wsl2-windows-android-studio-complete-guide-4493',
		};
		const res = await url_router.request(
			'/title',
			{
				method: 'POST',
				body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const data = await res.json();
		expect(res.status).toBe(200);
		expect(data.url).toBe(body.url);
		expect(data.title).toBeDefined();
		expect(data.title.length).toBeGreaterThan(0);
	});

	it('POST /title with invalid URL', async () => {
		const body = {
			url: 'not-a-valid-url',
		};
		const res = await url_router.request(
			'/title',
			{
				method: 'POST',
				body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		expect(res.status).toBe(400);
	});
});
