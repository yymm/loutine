import 'dart:convert';
import 'dart:io';

import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:mobile_ui/models/paginated_result.dart';
import 'package:mobile_ui/exceptions/app_exceptions.dart';

/// Note関連のデータ取得を担当するRepository
///
/// 責務:
/// - APIクライアントを使ってデータを取得
/// - JSONレスポンスをNoteモデルに変換
/// - データ取得ロジックの抽象化
/// - エラーを適切なカスタム例外に変換
class NoteRepository {
  final NoteApiClient _apiClient;

  /// コンストラクタでAPIクライアントを注入
  /// これによりテスト時にモックAPIクライアントを渡せる
  NoteRepository(this._apiClient);

  /// 指定期間のノート一覧を取得
  ///
  /// APIから取得したJSONをパースしてNoteのリストに変換して返す
  ///
  /// 発生する可能性のある例外:
  /// - [NetworkException]: ネットワークエラー
  /// - [ServerException]: サーバーエラー
  /// - [ParseException]: JSONパースエラー
  Future<List<Note>> fetchNotes(DateTime startDate, DateTime endDate) async {
    try {
      final resBody = await _apiClient.list(startDate, endDate);
      final List<dynamic> json = jsonDecode(resBody);
      return json.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      throw ParseException('ノートデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      throw ParseException('ノートデータの形式が不正です: $e');
    }
  }

  /// 新しいノートを作成
  ///
  /// APIに送信して作成されたNoteを返す
  ///
  /// 発生する可能性のある例外:
  /// - [NetworkException]: ネットワークエラー
  /// - [ServerException]: サーバーエラー
  /// - [ParseException]: JSONパースエラー
  Future<Note> createNote({
    required String title,
    required String text,
    List<int> tagIds = const [],
  }) async {
    try {
      final resBody = await _apiClient.post(text, title, tagIds);
      final Map<String, dynamic> json = jsonDecode(resBody);
      return Note.fromJson(json);
    } on SocketException {
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      throw ParseException('作成されたノートデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      throw ParseException('作成されたノートデータの形式が不正です: $e');
    }
  }

  /// cursor/limitベースでノート一覧を取得（無限スクロール用）
  ///
  /// APIから取得したJSONをパースしてPaginatedResultに変換して返す
  ///
  /// バックエンドのレスポンス形式:
  /// ```json
  /// {
  ///   "notes": [...],
  ///   "next_cursor": "cursor_string",
  ///   "has_next_page": true
  /// }
  /// ```
  ///
  /// 発生する可能性のある例外:
  /// - [NetworkException]: ネットワークエラー
  /// - [ServerException]: サーバーエラー
  /// - [ParseException]: JSONパースエラー
  Future<PaginatedResult<Note>> fetchNotesPaginated({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final resBody = await _apiClient.listPaginated(cursor: cursor, limit: limit);
      final Map<String, dynamic> json = jsonDecode(resBody);
      
      // バックエンドは { notes, next_cursor, has_next_page } の形式
      final List<dynamic> notesJson = json['notes'] as List;
      final notes = notesJson
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return PaginatedResult(
        items: notes,
        nextCursor: json['next_cursor'] as String?,
        hasMore: json['has_next_page'] as bool? ?? false,
      );
    } on SocketException {
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      throw ParseException('ノートデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      throw ParseException('ノートデータの形式が不正です: $e');
    }
  }

  /// ノートを更新
  /// TODO: バックエンドのUpdate APIが実装されたら実装
  Future<Note> updateNote(Note note) async {
    throw UnimplementedError('Update API is not implemented yet');
  }

  /// ノートを削除
  /// TODO: バックエンドのDelete APIが実装されたら実装
  Future<void> deleteNote(int noteId) async {
    throw UnimplementedError('Delete API is not implemented yet');
  }

  /// IDでノートを取得
  /// TODO: バックエンドのGet by ID APIが実装されたら実装
  Future<Note?> getNoteById(int id) async {
    throw UnimplementedError('Get by ID API is not implemented yet');
  }
}
