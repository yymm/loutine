import { eq } from 'drizzle-orm';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { tags } from '../../schema';

export class TagsUsecase {
	db: DrizzleD1Database;

	constructor(db: DrizzleD1Database) {
		this.db = db;
	}

	async get_by_id(id: number) {
		const tag = this.db.select().from(tags).where(eq(tags.id, id)).get();
		return tag;
	}

	async get_all() {
		const all_tags = this.db.select().from(tags).limit(100).all();
		return all_tags;
	}

	async create({
		name,
		description,
	}: {
		name: string;
		description: string | null;
	}) {
		const new_tag = this.db
			.insert(tags)
			.values(description === null ? { name } : { name, description })
			.returning()
			.get();
		return new_tag;
	}

	async update({
		id,
		name,
		description,
	}: {
		id: number;
		name: string;
		description: string | null;
	}) {
		const updated_tag = await this.db
			.update(tags)
			.set(description === null ? { name } : { name, description })
			.where(eq(tags.id, id))
			.returning()
			.get();
		return updated_tag;
	}
}
