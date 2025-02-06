import { and, gte, lt } from 'drizzle-orm';
import {DrizzleD1Database} from "drizzle-orm/d1";
import {purchases} from "../../schema";

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
      .where(and(
        gte(purchases.created_at, start_date),
        lt(purchases.created_at, end_date),
      ))
      .all();
		return all_purchases;
  }
}
