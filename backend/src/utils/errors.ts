export const send_404 = (c: any, message = 'Not Found') => {
	return c.json({ success: false, message }, 404);
};
