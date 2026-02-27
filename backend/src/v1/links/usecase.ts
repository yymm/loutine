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
		const results = await this.db
			.select({
				id: links.id,
				title: links.title,
				url: links.url,
				created_at: links.created_at,
				updated_at: links.updated_at,
				tag_id: link_tag.tag_id,
			})
			.from(links)
			.leftJoin(link_tag, eq(links.id, link_tag.link_id))
			.where(eq(links.id, id))
			.all();

		if (results.length === 0) {
			return null;
		}

		const link = results[0];
		const tag_ids = results
			.map((r) => r.tag_id)
			.filter((tag_id): tag_id is number => tag_id !== null);

		return {
			id: link.id,
			title: link.title,
			url: link.url,
			created_at: link.created_at,
			updated_at: link.updated_at,
			tag_ids,
		};
	}

	async get_date_range(start_date: string, end_date: string) {
		const results = await this.db
			.select({
				id: links.id,
				title: links.title,
				url: links.url,
				created_at: links.created_at,
				updated_at: links.updated_at,
				tag_id: link_tag.tag_id,
			})
			.from(links)
			.leftJoin(link_tag, eq(links.id, link_tag.link_id))
			.where(
				and(gte(links.created_at, start_date), lt(links.created_at, end_date)),
			)
			.all();

		const links_map = new Map<
			number,
			{
				id: number;
				title: string;
				url: string;
				created_at: string;
				updated_at: string;
				tag_ids: number[];
			}
		>();

		for (const row of results) {
			if (!links_map.has(row.id)) {
				links_map.set(row.id, {
					id: row.id,
					title: row.title,
					url: row.url,
					created_at: row.created_at,
					updated_at: row.updated_at,
					tag_ids: [],
				});
			}
			if (row.tag_id !== null) {
				links_map.get(row.id)?.tag_ids.push(row.tag_id);
			}
		}

		return Array.from(links_map.values());
	}

	async get_latest_by_cursor(
		cursor_str: string | null | undefined,
		limit = 10,
	) {
		const limited_query = this.db
			.select({ id: links.id })
			.from(links)
			.orderBy(desc(links.created_at), desc(links.id))
			.limit(limit + 1);

		if (cursor_str !== null && cursor_str !== undefined) {
			const { last_created_at, last_id } = JSON.parse(
				atob(cursor_str),
			) as CursorPayload;
			limited_query.where(
				sql`(${links.created_at}, ${links.id}) < (${last_created_at}, ${last_id})`,
			);
		}

		const limited_links = await limited_query.all();
		const link_ids = limited_links.map((l) => l.id);

		if (link_ids.length === 0) {
			return { links: [], next_cursor: null, has_next_page: false };
		}

		const results = await this.db
			.select({
				id: links.id,
				title: links.title,
				url: links.url,
				created_at: links.created_at,
				updated_at: links.updated_at,
				tag_id: link_tag.tag_id,
			})
			.from(links)
			.leftJoin(link_tag, eq(links.id, link_tag.link_id))
			.where(sql`${links.id} IN ${link_ids}`)
			.orderBy(desc(links.created_at), desc(links.id))
			.all();

		const links_map = new Map<
			number,
			{
				id: number;
				title: string;
				url: string;
				created_at: string;
				updated_at: string;
				tag_ids: number[];
			}
		>();

		for (const row of results) {
			if (!links_map.has(row.id)) {
				links_map.set(row.id, {
					id: row.id,
					title: row.title,
					url: row.url,
					created_at: row.created_at,
					updated_at: row.updated_at,
					tag_ids: [],
				});
			}
			if (row.tag_id !== null) {
				links_map.get(row.id)?.tag_ids.push(row.tag_id);
			}
		}

		const all_links = Array.from(links_map.values());
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
