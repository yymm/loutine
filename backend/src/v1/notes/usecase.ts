import { and, gte, lt } from 'drizzle-orm';
import {DrizzleD1Database} from "drizzle-orm/d1";
import {notes} from "../../schema";

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
      .where(and(
        gte(notes.created_at, start_date),
        lt(notes.created_at, end_date),
      ))
      .all();
		return all_notes;
  }
}
