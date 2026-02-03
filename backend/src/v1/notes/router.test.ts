import { env } from 'cloudflare:test';
import { beforeEach, describe, expect, it } from 'vitest';
import { notes_router } from './router';
import { Note } from './types';

describe('notes router', () => {
	const body = {
		title: 'test note',
		text: 'test note content',
	};
	let createdNoteId: number;

	beforeEach(async () => {
		const res = await notes_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const note = (await res.json()) as { id: number };
		createdNoteId = note.id;
	});

	it('POST /', async () => {
		const newBody = {
			title: 'another note',
			text: 'another note content',
		};
		const res = await notes_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const note = (await res.json()) as { title: string; text: string };
		expect(res.status).toBe(201);
		expect(note.title).toBe(newBody.title);
		expect(note.text).toBe(newBody.text);
	});

	it('POST / with tag_ids', async () => {
		const newBody = {
			title: 'note with tags',
			text: 'note content with tags',
			tag_ids: [],
		};
		const res = await notes_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const note = (await res.json()) as { title: string; text: string };
		expect(res.status).toBe(201);
		expect(note.title).toBe(newBody.title);
		expect(note.text).toBe(newBody.text);
	});

	it('GET /:id', async () => {
		const res = await notes_router.request(`/${createdNoteId}`, {}, env);
		const note: Note = await res.json();
		expect(res.status).toBe(200);
		expect(note.title).toBe(body.title);
		expect(note.text).toBe(body.text);
	});

	it('GET / with date range', async () => {
		const res = await notes_router.request(
			'/?start_date=2020-01-01&end_date=2099-12-31',
			{},
			env,
		);
		const notes = await res.json();
		expect(res.status).toBe(200);
		expect(Array.isArray(notes)).toBe(true);
	});

	it('POST / without required fields', async () => {
		const invalidBody = {
			title: 'no text provided',
		};
		const res = await notes_router.request(
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
			id: createdNoteId,
			title: 'updated note title',
			text: '[{\\"insert\\":\\"テスト内容\\\\n\\"}]',
			tag_ids: [],
		};
		const res = await notes_router.request(
			`/`,
			{
				method: 'PUT',
				body: JSON.stringify(updateBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const note: Note = await res.json();
		expect(res.status).toBe(200);
		expect(note.title).toBe(updateBody.title);
		expect(note.text).toBe(updateBody.text);
	});

	it('DELETE /:id', async () => {
		const res = await notes_router.request(
			`/${createdNoteId}`,
			{ method: 'DELETE' },
			env,
		);
		expect(res.status).toBe(200);
	});
});
