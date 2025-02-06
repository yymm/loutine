import { eq } from 'drizzle-orm';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { categories } from '../../schema';

export class CategoriesUsecase {
	db: DrizzleD1Database;

	constructor(db: DrizzleD1Database) {
		this.db = db;
	}

	async get_by_id(id: number) {
		const category = await this.db
			.select()
			.from(categories)
			.where(eq(categories.id, id))
			.get();
		return category;
	}

	async get_all() {
		const all_categories = await this.db
			.select()
			.from(categories)
			.limit(10) // TODO: テスト用途なので適当に10件にしてある
			.all();
		return all_categories;
	}

	async create({
		name,
		description,
	}: { name: string; description: string | null }) {
		const new_category = await this.db
			.insert(categories)
			.values(description === null ? { name } : { name, description })
			.returning()
			.get();
		return new_category;
	}

	async update({
		id,
		name,
		description,
	}: { id: number; name: string; description: string | null }) {
		const updated_category = await this.db
			.update(categories)
			.set(description === null ? { name } : { name, description })
			.where(eq(categories.id, id))
			.returning()
			.get();
		return updated_category;
	}
}
