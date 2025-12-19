import { env } from 'cloudflare:test';
import { describe, expect, it, beforeEach } from 'vitest';
import { notes_router } from './router';

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
		const note = await res.json();
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
		const note = await res.json();
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
		const note = await res.json();
		expect(res.status).toBe(201);
		expect(note.title).toBe(newBody.title);
		expect(note.text).toBe(newBody.text);
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
});
