import { env } from 'cloudflare:test';
import { describe, expect, it } from 'vitest';
import { links_router } from './router';
import {Link} from './types';

describe('links router', () => {
  const body = {
    title: 'example title',
    url: 'https://example.com',
  };

  beforeAll(async () => {
    await links_router.request(
      '/',
      {
        method: 'POST',
        body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
      },
      env,
    );
  })

	it('GET /1', async () => {
    const res = await links_router.request("/1", {}, env);
    const link: Link = await res.json();
    expect(res.status).toBe(200);
    expect(link.title).toBe(body.title);
    expect(link.url).toBe(body.url);
	});
});
