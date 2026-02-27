import { and, desc, eq, gte, lt, sql } from 'drizzle-orm';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { note_tag, notes } from '../../schema';

type CursorPayload = {
	last_created_at: string;
	last_id: number;
};

export class NotesUsecase {
	db: DrizzleD1Database;

	constructor(db: DrizzleD1Database) {
		this.db = db;
	}

	async get_by_id(id: number) {
		const results = await this.db
			.select({
				id: notes.id,
				title: notes.title,
				text: notes.text,
				created_at: notes.created_at,
				updated_at: notes.updated_at,
				tag_id: note_tag.tag_id,
			})
			.from(notes)
			.leftJoin(note_tag, eq(notes.id, note_tag.note_id))
			.where(eq(notes.id, id))
			.all();

		if (results.length === 0) {
			return null;
		}

		const note = results[0];
		const tag_ids = results
			.map((r) => r.tag_id)
			.filter((tag_id): tag_id is number => tag_id !== null);

		return {
			id: note.id,
			title: note.title,
			text: note.text,
			created_at: note.created_at,
			updated_at: note.updated_at,
			tag_ids,
		};
	}

	async get_date_range(start_date: string, end_date: string) {
		const results = await this.db
			.select({
				id: notes.id,
				title: notes.title,
				text: notes.text,
				created_at: notes.created_at,
				updated_at: notes.updated_at,
				tag_id: note_tag.tag_id,
			})
			.from(notes)
			.leftJoin(note_tag, eq(notes.id, note_tag.note_id))
			.where(
				and(gte(notes.created_at, start_date), lt(notes.created_at, end_date)),
			)
			.all();

		const notes_map = new Map<
			number,
			{
				id: number;
				title: string;
				text: string;
				created_at: string;
				updated_at: string;
				tag_ids: number[];
			}
		>();

		for (const row of results) {
			if (!notes_map.has(row.id)) {
				notes_map.set(row.id, {
					id: row.id,
					title: row.title,
					text: row.text,
					created_at: row.created_at,
					updated_at: row.updated_at,
					tag_ids: [],
				});
			}
			if (row.tag_id !== null) {
				notes_map.get(row.id)?.tag_ids.push(row.tag_id);
			}
		}

		return Array.from(notes_map.values());
	}

	async get_latest_by_cursor(
		cursor_str: string | null | undefined,
		limit = 10,
	) {
		const limited_query = this.db
			.select({ id: notes.id })
			.from(notes)
			.orderBy(desc(notes.created_at), desc(notes.id))
			.limit(limit + 1);

		if (cursor_str !== null && cursor_str !== undefined) {
			const { last_created_at, last_id } = JSON.parse(
				atob(cursor_str),
			) as CursorPayload;
			limited_query.where(
				sql`(${notes.created_at}, ${notes.id}) < (${last_created_at}, ${last_id})`,
			);
		}

		const limited_notes = await limited_query.all();
		const note_ids = limited_notes.map((n) => n.id);

		if (note_ids.length === 0) {
			return { notes: [], next_cursor: null, has_next_page: false };
		}

		const results = await this.db
			.select({
				id: notes.id,
				title: notes.title,
				text: notes.text,
				created_at: notes.created_at,
				updated_at: notes.updated_at,
				tag_id: note_tag.tag_id,
			})
			.from(notes)
			.leftJoin(note_tag, eq(notes.id, note_tag.note_id))
			.where(sql`${notes.id} IN ${note_ids}`)
			.orderBy(desc(notes.created_at), desc(notes.id))
			.all();

		const notes_map = new Map<
			number,
			{
				id: number;
				title: string;
				text: string;
				created_at: string;
				updated_at: string;
				tag_ids: number[];
			}
		>();

		for (const row of results) {
			if (!notes_map.has(row.id)) {
				notes_map.set(row.id, {
					id: row.id,
					title: row.title,
					text: row.text,
					created_at: row.created_at,
					updated_at: row.updated_at,
					tag_ids: [],
				});
			}
			if (row.tag_id !== null) {
				notes_map.get(row.id)?.tag_ids.push(row.tag_id);
			}
		}

		const all_notes = Array.from(notes_map.values());
		const has_next_page = all_notes.length > limit;
		const return_notes = has_next_page ? all_notes.slice(0, limit) : all_notes;
		let next_cursor: string | null = null;
		if (has_next_page && return_notes.length > 0) {
			const last_note = return_notes[return_notes.length - 1];
			next_cursor = btoa(
				JSON.stringify({
					last_created_at: last_note.created_at,
					last_id: last_note.id,
				}),
			);
		}

		return { notes: return_notes, next_cursor, has_next_page };
	}

	async create({
		title,
		text,
		tag_ids,
	}: {
		title: string;
		text: string;
		tag_ids: Array<number> | null | undefined;
	}) {
		// FIXME: Since D1 lacks transaction functionality,
		// you'll either have to implement your own rollback mechanism
		// or wait for transactions to be implemented.
		const new_note = await this.db
			.insert(notes)
			.values({ title, text })
			.returning()
			.get();
		if (tag_ids !== null && tag_ids !== undefined) {
			for (const tag_id of tag_ids) {
				await this.db
					.insert(note_tag)
					.values({ note_id: new_note.id, tag_id })
					.returning()
					.get();
			}
		}
		return new_note;
	}

	async update({
		id,
		title,
		text,
		tag_ids,
	}: {
		id: number;
		title: string;
		text: string;
		tag_ids: Array<number> | null | undefined;
	}) {
		// FIXME: Since D1 lacks transaction functionality,
		// you'll either have to implement your own rollback mechanism
		// or wait for transactions to be implemented.
		const updated_note = await this.db
			.update(notes)
			.set({ title, text })
			.where(eq(notes.id, id))
			.returning()
			.get();
		if (tag_ids !== null && tag_ids !== undefined) {
			await this.db.delete(note_tag).where(eq(note_tag.note_id, id));
			for (const tag_id of tag_ids) {
				await this.db.insert(note_tag).values({ note_id: id, tag_id });
			}
		}
		return updated_note;
	}

	async delete(id: number) {
		await this.db.delete(note_tag).where(eq(note_tag.note_id, id));
		const deleted_note = await this.db
			.delete(notes)
			.where(eq(notes.id, id))
			.returning()
			.get();
		return deleted_note;
	}
}
