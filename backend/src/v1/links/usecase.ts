import { and, desc, eq, gte, lt, sql } from 'drizzle-orm';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { link_tag, links } from '../../schema';

type CursorPayload = {
	last_created_at: string;
	last_id: number;
};

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

	async get_latest_by_cursor(
		cursor_str: string | null | undefined,
		limit = 10,
	) {
		const query = this.db
			.select()
			.from(links)
			.orderBy(desc(links.created_at), desc(links.id))
			.limit(limit + 1);

		if (cursor_str !== null && cursor_str !== undefined) {
			const { last_created_at, last_id } = JSON.parse(
				atob(cursor_str),
			) as CursorPayload;
			query.where(
				sql`(${links.created_at}, ${links.id}) < (${last_created_at}, ${last_id})`,
			);
		}

		const all_links = await query.all();

		const has_next_page = all_links.length > limit;
		const return_links = has_next_page ? all_links.slice(0, limit) : all_links;
		let next_cursor: string | null = null;
		if (has_next_page && return_links.length > 0) {
			const last_link = return_links[return_links.length - 1];
			next_cursor = btoa(
				JSON.stringify({
					last_created_at: last_link.created_at,
					last_id: last_link.id,
				}),
			);
		}

		return { links: return_links, next_cursor, has_next_page };
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
		await this.db.delete(link_tag).where(eq(link_tag.link_id, id));
		const deleted_link = await this.db
			.delete(links)
			.where(eq(links.id, id))
			.returning()
			.get();
		return deleted_link;
	}
}
