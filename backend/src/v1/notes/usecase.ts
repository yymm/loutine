import { and, eq, gte, lt } from 'drizzle-orm';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { note_tag, notes } from '../../schema';

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
		const deleted_note = await this.db
			.delete(notes)
			.where(eq(notes.id, id))
			.returning()
			.get();
		return deleted_note;
	}
}
