import { and, eq, gte, lt } from 'drizzle-orm';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { purchases } from '../../schema';

export class PurchasesUsecase {
	db: DrizzleD1Database;

	constructor(db: DrizzleD1Database) {
		this.db = db;
	}

	async get_by_id(id: number) {
		const purchase = await this.db
			.select()
			.from(purchases)
			.where(eq(purchases.id, id))
			.get();
		return purchase;
	}

	async get_date_range(start_date: string, end_date: string) {
		const all_purchases = await this.db
			.select()
			.from(purchases)
			.where(
				and(
					gte(purchases.created_at, start_date),
					lt(purchases.created_at, end_date),
				),
			)
			.all();
		return all_purchases;
	}

	async create({
		title,
		cost,
		category_id,
	}: {
		title: string;
		cost: number;
		category_id: number | null | undefined;
	}) {
		const values =
			category_id !== null && category_id !== undefined
				? { title, cost, category_id }
				: { title, cost };
		const new_purchase = await this.db
			.insert(purchases)
			.values(values)
			.returning()
			.get();
		return new_purchase;
	}

	async update({
		id,
		title,
		cost,
		category_id,
	}: {
		id: number;
		title: string;
		cost: number;
		category_id: number | null | undefined;
	}) {
		const values =
			category_id !== null && category_id !== undefined
				? { title, cost, category_id }
				: { title, cost };
		const new_purchase = await this.db
			.update(purchases)
			.set(values)
			.returning()
			.get();
		return new_purchase;
	}

	async delete(id: number) {
		const deleted_purchase = await this.db
			.delete(purchases)
			.where(eq(purchases.id, id))
			.returning()
			.get();
		return deleted_purchase;
	}
}
