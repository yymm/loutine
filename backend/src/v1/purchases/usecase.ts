import { and, gte, lt } from 'drizzle-orm';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { purchases } from '../../schema';

export class PurchasesUsecase {
	db: DrizzleD1Database;

	constructor(db: DrizzleD1Database) {
		this.db = db;
	}

	async get_date_range(start_date: string, end_date: string) {
		const all_purchases = await this.db
			.select()
			.from(purchases)
			.limit(10)
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
}
