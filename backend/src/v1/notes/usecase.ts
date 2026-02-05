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
		const note = await this.db
			.select()
			.from(notes)
			.where(eq(notes.id, id))
			.get();
		return note;
	}

	async get_date_range(start_date: string, end_date: string) {
		const all_notes = await this.db
			.select()
			.from(notes)
			.limit(10)
			.where(
				and(gte(notes.created_at, start_date), lt(notes.created_at, end_date)),
			)
			.all();
		return all_notes;
	}

	async get_latest_by_cursor(
		cursor_str: string | null | undefined,
		limit = 10,
	) {
		const query = this.db
			.select()
			.from(notes)
			.orderBy(desc(notes.created_at), desc(notes.id))
			.limit(limit + 1);

		if (cursor_str !== null && cursor_str !== undefined) {
			const { last_created_at, last_id } = JSON.parse(
				atob(cursor_str),
			) as CursorPayload;
			query.where(
				sql`(${notes.created_at}, ${notes.id}) < (${last_created_at}, ${last_id})`,
			);
		}

		const all_notes = await query.all();

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
