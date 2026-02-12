/// ページネーション結果の汎用クラス
///
/// cursor/limit APIのレスポンスを表現する
class PaginatedResult<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });
}
