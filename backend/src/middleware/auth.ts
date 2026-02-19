import type { Context, Next } from 'hono';
import { HTTPException } from 'hono/http-exception';
import type { Env } from '../utils/app_factory';

export const customAuthMiddleware = async (c: Context<Env>, next: Next) => {
	const authKey = c.req.header('X-Custom-Auth-Key');
	const expectedKey = c.env.CUSTOM_AUTH_KEY;

	// 環境変数が未設定 = エラー（fail-closed）
	if (!expectedKey) {
		throw new HTTPException(500, {
			res: c.json(
				{
					success: false,
					message: 'Server misconfiguration: authentication key not configured',
				},
				500,
			),
		});
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
