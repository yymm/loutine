import { and, gte, lt } from 'drizzle-orm';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { note_tag, notes } from '../../schema';

export class NotesUsecase {
	db: DrizzleD1Database;

	constructor(db: DrizzleD1Database) {
		this.db = db;
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
				this.db
					.insert(note_tag)
					.values({ note_id: new_note.id, tag_id })
					.returning()
					.get();
			}
		}
		return new_note;
	}
}
