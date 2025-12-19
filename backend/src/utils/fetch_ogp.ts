interface OGPData {
  title?: string;
  description?: string;
  image?: string;
  url?: string;
  site_name?: string;
}

export const empty_ogp = {
  title: '',
  description: '',
  image: '',
  url: '',
  site_name: '',
}

/**
 * Fetch APIと正規表現のみでOGP情報を取得する
 */
export const fetch_url_ogp = async (targetUrl: string): Promise<OGPData | null> => {
  try {
    const response = await fetch(targetUrl, {
      headers: { 'User-Agent': 'Mozilla/5.0 (compatible; Googlebot/2.1)' }
    });

    if (!response.ok) return null;
    const html = await response.text();

    // ヘッダー部分のみを抽出して処理を高速化
    const headMatch = html.match(/<head[\s\S]*?>([\s\S]*?)<\/head>/i);
    const headInner = headMatch ? headMatch[1] : html;

    const ogp: OGPData = {};

    // 抽出対象のプロパティ定義
    const properties: Record<string, keyof OGPData> = {
      'og:title': 'title',
      'og:description': 'description',
      'og:image': 'image',
      'og:url': 'url',
      'og:site_name': 'site_name'
    };

    // metaタグを抽出するための正規表現
    // property="..." と content="..." の順番が逆でも、間に他の属性があってもマッチするように設計
    for (const [ogProp, key] of Object.entries(properties)) {
      const regex = new RegExp(
        `<meta[^>]+(?:property|name)=["']${ogProp}["'][^>]+content=["']([^"']+)["']`,
        'i'
      );
      const revRegex = new RegExp(
        `<meta[^>]+content=["']([^"']+)["'][^>]+(?:property|name)=["']${ogProp}["']`,
        'i'
      );

      const match = headInner.match(regex) || headInner.match(revRegex);
      if (match) {
        // ogp[key] = decodeHtmlEntities(match[1]);
        ogp[key] = match[1].trim();
      }
    }

    // フォールバック: <title>タグの抽出
    if (!ogp.title) {
      const titleMatch = headInner.match(/<title(?:\s+[^>]*)?>([\s\S]*?)<\/title>/i);
      // if (titleMatch) ogp.title = decodeHtmlEntities(titleMatch[1].trim());
      if (titleMatch) ogp.title = titleMatch[1].trim();
    }

    return ogp;
  } catch (e) {
    console.error(e);
    return null;
  }
}
