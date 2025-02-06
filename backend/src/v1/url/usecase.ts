export class UrlUsecase {
  async get_url_title(url: string) {
    const response = await fetch(url);

    if (!response.ok) {
      // throw new Error(`HTTP error! status: ${response.status}`);
      return '';
    }

    const html = await response.text();

    const titleMatch = html.match(/<title>(.*?)<\/title>/i);
    if (titleMatch && titleMatch[1]) {
      return titleMatch[1].trim();
    }
    // 取得できない場合はエラーにせず空文字を返す仕様
    return '';
  }
}
