import type { Context, Next } from 'hono';
import { HTTPException } from 'hono/http-exception';
import type { Env } from '../utils/app_factory';

export const customAuthMiddleware = async (c: Context<Env>, next: Next) => {
	const authKey = c.req.header('X-Custom-Auth-Key');
	const expectedKey = c.env.CUSTOM_AUTH_KEY;

	if (!expectedKey) {
		console.warn('CUSTOM_AUTH_KEY is not configured. Skipping auth check.');
		await next();
		return;
	}

	if (!authKey) {
		throw new HTTPException(401, {
			message: 'Missing X-Custom-Auth-Key header',
		});
	}

	if (authKey !== expectedKey) {
		throw new HTTPException(403, {
			message: 'Invalid authentication key',
		});
	}

	await next();
};
