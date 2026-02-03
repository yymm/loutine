import { and, eq, gte, lt } from 'drizzle-orm';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { link_tag, links } from '../../schema';

export class LinksUsecase {
	db: DrizzleD1Database;

	constructor(db: DrizzleD1Database) {
		this.db = db;
	}

	async get_by_id(id: number) {
		const link = await this.db
			.select()
			.from(links)
			.where(eq(links.id, id))
			.get();
		return link;
	}

	async get_date_range(start_date: string, end_date: string) {
		const all_links = await this.db
			.select()
			.from(links)
			.where(
				and(gte(links.created_at, start_date), lt(links.created_at, end_date)),
			)
			.all();
		return all_links;
	}

	async create({
		title,
		url,
		tag_ids,
	}: {
		title: string;
		url: string;
		tag_ids: Array<number> | null | undefined;
	}) {
		// FIXME: Since D1 lacks transaction functionality,
		// you'll either have to implement your own rollback mechanism
		// or wait for transactions to be implemented.
		const new_link = await this.db
			.insert(links)
			.values({ title, url })
			.returning()
			.get();
		if (tag_ids !== null && tag_ids !== undefined) {
			for (const tag_id of tag_ids) {
				await this.db
					.insert(link_tag)
					.values({ link_id: new_link.id, tag_id })
					.returning()
					.get();
			}
		}
		return new_link;
	}

	async update({
		id,
		title,
		url,
		tag_ids,
	}: {
		id: number;
		title: string;
		url: string;
		tag_ids: Array<number> | null | undefined;
	}) {
		// FIXME: Since D1 lacks transaction functionality,
		// you'll either have to implement your own rollback mechanism
		// or wait for transactions to be implemented.
		const updated_link = await this.db
			.update(links)
			.set({ title, url })
			.where(eq(links.id, id))
			.returning()
			.get();
		if (tag_ids !== null && tag_ids !== undefined) {
			await this.db.delete(link_tag).where(eq(link_tag.link_id, id));
			for (const tag_id of tag_ids) {
				await this.db
					.insert(link_tag)
					.values({ link_id: id, tag_id })
					.returning()
					.get();
			}
		}
		return updated_link;
	}

	async delete(id: number) {
		const deleted_link = await this.db
			.delete(links)
			.where(eq(links.id, id))
			.returning()
			.get();
		return deleted_link;
	}
}
