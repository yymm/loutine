import { empty_ogp, fetch_url_ogp } from '../../utils/fetch_ogp';
import { fetch_url_title } from '../../utils/fetch_url_title';

export class UrlUsecase {
	async get_url_title(url: string) {
		const title = await fetch_url_title(url);
		if (title === null) {
			console.warn('Failed to fetch url title (fetch_url_title)');
			return '';
		}
		return title;
	}

	async get_url_ogp(url: string) {
		const ogp = await fetch_url_ogp(url);
		if (ogp === null) {
			console.warn('Failed to fetch url ogp (fetch_url_ogp)');
			return empty_ogp;
		}
		return ogp;
	}
}
