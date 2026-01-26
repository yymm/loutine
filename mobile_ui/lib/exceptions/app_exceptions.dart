/// アプリケーション全体で使用するカスタム例外の基底クラス
///
/// すべてのカスタム例外はこのクラスを継承します。
/// これにより、アプリケーション固有のエラーと
/// システムエラーを区別できます。
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// ネットワーク接続に関する例外
///
/// 利用例:
/// - インターネット接続がない
/// - タイムアウト
/// - DNS解決失敗
///
/// この例外が発生した場合、ユーザーに
/// 「ネットワーク接続を確認してください」と表示すべきです。
class NetworkException extends AppException {
  const NetworkException([String message = 'ネットワークエラーが発生しました'])
      : super(message);
}

/// サーバーからのエラーレスポンスに関する例外
///
/// 利用例:
/// - 400 Bad Request
/// - 404 Not Found
/// - 500 Internal Server Error
///
/// statusCodeとメッセージを保持することで、
/// 詳細なエラー情報をログやユーザーに提供できます。
class ServerException extends AppException {
  const ServerException(this.statusCode, [String? message])
      : super(message ?? 'サーバーエラーが発生しました (ステータス: $statusCode)');

  final int statusCode;

  /// サーバーエラーかどうかを判定（5xx）
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  /// クライアントエラーかどうかを判定（4xx）
  bool get isClientError => statusCode >= 400 && statusCode < 500;
}

/// JSONパース・データ変換に関する例外
///
/// 利用例:
/// - JSONの構造が期待と異なる
/// - 必須フィールドが欠けている
/// - 型変換に失敗
///
/// この例外が発生した場合、通常はアプリ側のバグか、
/// APIのバージョン不一致を示します。
class ParseException extends AppException {
  const ParseException([String message = 'データの解析に失敗しました']) : super(message);
}
