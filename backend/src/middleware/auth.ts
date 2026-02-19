import type { Context, Next } from 'hono';
import { HTTPException } from 'hono/http-exception';
import type { Env } from '../utils/app_factory';

let hasLoggedMissingAuthKey = false;

export const customAuthMiddleware = async (c: Context<Env>, next: Next) => {
	const authKey = c.req.header('X-Custom-Auth-Key');
	const expectedKey = c.env.CUSTOM_AUTH_KEY;

	if (!expectedKey) {
		if (!hasLoggedMissingAuthKey) {
			console.warn('CUSTOM_AUTH_KEY is not configured. Skipping auth check.');
			hasLoggedMissingAuthKey = true;
		}
		await next();
		return;
	}

	if (!authKey) {
		throw new HTTPException(401, {
			res: c.json(
				{
					success: false,
					message: 'Missing X-Custom-Auth-Key header',
				},
				401,
			),
		});
	}

	if (authKey !== expectedKey) {
		throw new HTTPException(403, {
			res: c.json(
				{
					success: false,
					message: 'Invalid authentication key',
				},
				403,
			),
		});
	}

	await next();
};
