import { env } from 'cloudflare:test';
import { beforeEach, describe, expect, it } from 'vitest';
import { notes_router } from './router';
import type { Note } from './types';
import { tags_router } from '../tags/router';
import type { Tag } from '../tags/types';

describe('notes router', () => {
	const body = {
		title: 'test note',
		text: 'test note content',
	};
	const tag_body = {
		name: 'test tag',
		description: 'test tag description',
	};
	let created_note_id: number;
	let created_tag_id: number;

	beforeEach(async () => {
		const resNote = await notes_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const note: Note = await resNote.json();
		created_note_id = note.id;
		const resTag = await tags_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(tag_body),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const tag: Tag = await resTag.json();
		created_tag_id = tag.id;
	});

	it('POST /', async () => {
		const newBody = {
			title: 'another note',
			text: '[{\\"insert\\":\\"テスト内容\\\\n\\"}]',
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
		const note: Note = await res.json();
		expect(res.status).toBe(201);
		expect(note.title).toBe(newBody.title);
		expect(note.text).toBe(newBody.text);
	});

	it('POST / with tag_ids', async () => {
		const newBody = {
			title: 'note with tags',
			text: '[{\\"insert\\":\\"テスト内容\\\\n\\"}]',
			tag_ids: [created_tag_id],
		};
		console.log('=======================');
		console.log(newBody);
		console.log('=======================');
		const res = await notes_router.request(
			'/',
			{
				method: 'POST',
				body: JSON.stringify(newBody),
				headers: new Headers({ 'Content-Type': 'application/json' }),
			},
			env,
		);
		const note: Note = await res.json();
		expect(res.status).toBe(201);
		expect(note.title).toBe(newBody.title);
		expect(note.text).toBe(newBody.text);
	});

	it('GET /:id', async () => {
		const res = await notes_router.request(`/${created_note_id}`, {}, env);
		const note: Note = await res.json();
		expect(res.status).toBe(200);
		expect(note.title).toBe(body.title);
		expect(note.text).toBe(body.text);
	});

	it('GET /:id mismatch param', async () => {
		const res = await notes_router.request(`/xxxx`, {}, env);
		expect(res.status).toBe(400);
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

	it('GET / missing param', async () => {
		const res = await notes_router.request('/?start_date=2020-01-01', {}, env);
		expect(res.status).toBe(400);
	});

	it('GET / mismatch param', async () => {
		const res = await notes_router.request(
			'/?start_date=xxx&end_date=xxxx',
			{},
			env,
		);
		expect(res.status).toBe(400);
	});

	it('GET /latest ', async () => {
		const res = await notes_router.request('/latest?limit=5', {}, env);
		const cursor_res = (await res.json()) as {
			notes: Array<Note>;
			next_cursor: string;
			has_next_page: boolean;
		};
		expect(res.status).toBe(200);
		expect(Array.isArray(cursor_res.notes)).toBe(true);
	});

	it('GET /latest mismatch param', async () => {
		const res = await notes_router.request('/latest?limit=xxxx', {}, env);
		expect(res.status).toBe(400);
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
			id: created_note_id,
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

	it('PUT / missing param', async () => {
		const updateBody = {
			title: 'no id and text provided',
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
		expect(res.status).toBe(400);
	});

	it('DELETE /:id', async () => {
		const res = await notes_router.request(
			`/${created_note_id}`,
			{ method: 'DELETE' },
			env,
		);
		expect(res.status).toBe(200);
	});
});
