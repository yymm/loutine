export const fetch_url_title = async (url: string): Promise<string | null> => {
  const response = await fetch(url, {
    headers: { 'User-Agent': 'Mozilla/5.0 (compatible; Googlebot/2.1)' }
  });

  // 取得できない場合はエラーにせず空文字を返す仕様
  if (!response.ok) {
    console.warn(`Failed to get url title, HTTP error! status: ${response.statusText}`)
    return '';
  }

  const htmlString = await response.text();

  const titleRegex = /<title(?:\s+[^>]*)?>([\s\S]*?)<\/title>/i;
  const match = htmlString.match(titleRegex);

  if (match && match[1]) {
    // HTMLエンティティ（&amp; 等）が含まれる可能性があるため、必要に応じてデコード処理を推奨
    return match[1].trim();
  }

  return null;
};
