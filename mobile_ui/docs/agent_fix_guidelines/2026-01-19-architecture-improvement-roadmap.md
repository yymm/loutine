# Flutter アーキテクチャ改善ロードマップ

作成日: 2026-01-19
更新日: 2026-01-19

## 📊 現在の構成

```
lib/
├── api/           # APIクライアント
├── models/        # データモデル
├── state/         # Riverpod状態管理
├── storage.dart   # SharedPreferences (ThemeMode永続化)
└── ui/            # UIコンポーネント
```

**プロジェクト規模**:
- 総ファイル数: 43ファイル
- 総行数: 約2,300行
- モデル数: 6種類（Tag, Category, Link, Note, Purchase, CalendarEventItem）
- API: シンプルなCRUD操作のみ
- ローカルストレージ: SharedPreferences（設定のみ）

## ⚠️ 主な課題と一般的な構成との差分

### 1. レイヤー分離の不足

**現状**: `StateNotifier`内で直接APIクライアントをインスタンス化

```dart
// state/tag_list_state.dart (現状)
Future<void> add(String name, String description) async {
  final TagApiClient apiClient = TagApiClient();  // ❌ 直接生成
  final resBody = await apiClient.post(name, description);
  ...
}
```

**問題点**:
- テストが困難（APIクライアントのモック化ができない）
- 依存関係が固定化される
- 関心の分離ができていない
- 将来的なローカルキャッシュ追加時に大規模な改修が必要

**将来的なニーズ（想定）**:
1. **オフライン対応** - ネットワークなしでTag/Categoryを表示、過去のLink/Purchase/Noteを閲覧
2. **パフォーマンス改善** - 初回表示の高速化（キャッシュ）、APIリクエスト削減
3. **検索機能** - ローカルDBでの全文検索、期間を跨いだ集計
4. **下書き機能** - オフライン時の新規作成、同期前のデータ保持

**一般的**: Repository層を挟んで依存性注入

#### Option A: シンプルなRepository（Phase 1-2向け）

```dart
// repositories/tag_repository.dart
class TagRepository {
  final TagApiClient _apiClient;
  TagRepository(this._apiClient);
  
  Future<List<Tag>> fetchTags() async {
    final resBody = await _apiClient.list();
    return (jsonDecode(resBody) as List)
        .map((e) => Tag.fromJson(e))
        .toList();
  }
}

// providers/repository_provider.dart
@riverpod
TagApiClient tagApiClient(TagApiClientRef ref) => TagApiClient();

@riverpod
TagRepository tagRepository(TagRepositoryRef ref) {
  return TagRepository(ref.watch(tagApiClientProvider));
}

// providers/tag_provider.dart
@riverpod
class TagList extends _$TagList {
  @override
  FutureOr<List<Tag>> build() => _fetch();
  
  Future<List<Tag>> _fetch() async {
    final repo = ref.read(tagRepositoryProvider);
    return repo.fetchTags();
  }
}
```

**メリット**:
- テスト時にRepositoryをモック化可能
- APIクライアントの実装変更が容易
- 関心の分離が明確

#### Option B: DataSource分離 + Repository（Phase 3-5向け、ローカルストレージ対応）

**データフロー**:
```
UI (Widget)
    ↕
Provider (Riverpod)
    ↕
Repository (ビジネスロジック + データソース選択)
    ↕ ← キャッシュ戦略、オフライン判定
    ├─→ RemoteDataSource (API) ──→ JSON
    └─→ LocalDataSource (DB)   ──→ SQLite/Drift
```

```dart
// data/datasources/remote/tag_remote_datasource.dart
class TagRemoteDataSource {
  final http.Client _client;
  TagRemoteDataSource(this._client);
  
  Future<List<TagModel>> getTags() async {
    final url = Uri.parse('$baseUrl/api/v1/tags');
    final res = await _client.get(url);
    
    if (res.statusCode != 200) {
      throw ServerException(res.statusCode);
    }
    
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return json.map((e) => TagModel.fromJson(e)).toList();
  }
  
  Future<TagModel> createTag(String name, String description) async {
    final url = Uri.parse('$baseUrl/api/v1/tags');
    final body = json.encode({'name': name, 'description': description});
    final res = await _client.post(
      url,
      headers: {'content-type': 'application/json'},
      body: body,
    );
    
    if (res.statusCode != 201) {
      throw ServerException(res.statusCode);
    }
    
    final jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return TagModel.fromJson(jsonData);
  }
}

// data/datasources/local/tag_local_datasource.dart
class TagLocalDataSource {
  final AppDatabase _db;  // drift database
  TagLocalDataSource(this._db);
  
  Future<List<TagModel>> getTags() async {
    final tags = await _db.select(_db.tagTable).get();
    return tags.map((e) => TagModel.fromDb(e)).toList();
  }
  
  Future<void> saveTags(List<TagModel> tags) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.tagTable,
        tags.map((e) => e.toCompanion()).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }
  
  Future<TagModel> saveTag(TagModel tag) async {
    await _db.into(_db.tagTable).insert(
      tag.toCompanion(),
      mode: InsertMode.insertOrReplace,
    );
    return tag;
  }
  
  Future<DateTime?> getLastSyncTime() async {
    final pref = SharedPreferencesInstance().prefs;
    final timestamp = pref.getInt('tags_last_sync');
    return timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }
  
  Future<void> setLastSyncTime(DateTime time) async {
    final pref = SharedPreferencesInstance().prefs;
    await pref.setInt('tags_last_sync', time.millisecondsSinceEpoch);
  }
}

// data/repositories/tag_repository.dart (キャッシュ戦略実装)
class TagRepository {
  final TagRemoteDataSource _remote;
  final TagLocalDataSource _local;
  final Connectivity _connectivity;  // connectivity_plusパッケージ
  
  TagRepository(this._remote, this._local, this._connectivity);
  
  // キャッシュ戦略: Cache-First
  Future<List<Tag>> getTags({bool forceRefresh = false}) async {
    try {
      // オンライン & (強制更新 or キャッシュ期限切れ)
      final isOnline = await _connectivity.checkConnectivity() != ConnectivityResult.none;
      final shouldFetch = forceRefresh || await _shouldRefreshCache();
      
      if (isOnline && shouldFetch) {
        // リモートから取得してローカルに保存
        final remoteTags = await _remote.getTags();
        await _local.saveTags(remoteTags);
        await _local.setLastSyncTime(DateTime.now());
        return remoteTags.map((e) => e.toEntity()).toList();
      }
      
      // キャッシュから取得
      final localTags = await _local.getTags();
      return localTags.map((e) => e.toEntity()).toList();
      
    } on ServerException {
      // APIエラー時はキャッシュから
      final localTags = await _local.getTags();
      if (localTags.isEmpty) rethrow;
      return localTags.map((e) => e.toEntity()).toList();
    } on SocketException {
      // ネットワークエラー時はキャッシュから
      final localTags = await _local.getTags();
      if (localTags.isEmpty) {
        throw const NetworkException('オフラインです');
      }
      return localTags.map((e) => e.toEntity()).toList();
    }
  }
  
  Future<Tag> createTag(String name, String description) async {
    final isOnline = await _connectivity.checkConnectivity() != ConnectivityResult.none;
    
    if (!isOnline) {
      // オフライン時はローカルに一時保存（同期待ち）
      final tempTag = TagModel.temp(name: name, description: description);
      await _local.saveTag(tempTag);
      return tempTag.toEntity();
    }
    
    // オンライン時はAPIに送信してローカルにも保存
    final remoteTag = await _remote.createTag(name, description);
    await _local.saveTag(remoteTag);
    return remoteTag.toEntity();
  }
  
  Future<bool> _shouldRefreshCache() async {
    final lastSync = await _local.getLastSyncTime();
    if (lastSync == null) return true;
    
    final cacheValidDuration = const Duration(minutes: 30);
    return DateTime.now().difference(lastSync) > cacheValidDuration;
  }
  
  // 同期処理（バックグラウンドで実行）
  Future<void> syncPendingTags() async {
    final pendingTags = await _local.getPendingTags();
    for (final tag in pendingTags) {
      try {
        final synced = await _remote.createTag(tag.name, tag.description);
        await _local.updateTag(tag.id, synced);
      } catch (e) {
        // 同期失敗はログ記録のみ（次回リトライ）
        print('Failed to sync tag: ${tag.id}');
      }
    }
  }
}

// providers/datasource_provider.dart
@riverpod
http.Client httpClient(HttpClientRef ref) => http.Client();

@riverpod
Connectivity connectivity(ConnectivityRef ref) => Connectivity();

@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}

@riverpod
TagRemoteDataSource tagRemoteDataSource(TagRemoteDataSourceRef ref) {
  return TagRemoteDataSource(ref.watch(httpClientProvider));
}

@riverpod
TagLocalDataSource tagLocalDataSource(TagLocalDataSourceRef ref) {
  return TagLocalDataSource(ref.watch(appDatabaseProvider));
}

@riverpod
TagRepository tagRepository(TagRepositoryRef ref) {
  return TagRepository(
    ref.watch(tagRemoteDataSourceProvider),
    ref.watch(tagLocalDataSourceProvider),
    ref.watch(connectivityProvider),
  );
}

// providers/tag_provider.dart
@riverpod
class TagList extends _$TagList {
  @override
  Future<List<Tag>> build() async {
    final repo = ref.watch(tagRepositoryProvider);
    return repo.getTags();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(tagRepositoryProvider);
      return repo.getTags(forceRefresh: true);
    });
  }
  
  Future<void> create(String name, String description) async {
    final repo = ref.read(tagRepositoryProvider);
    await repo.createTag(name, description);
    ref.invalidateSelf();
  }
}
```

**メリット**:
- データソースの透過的な切り替え（Repositoryが自動判断）
- オフライン対応が容易（ローカルキャッシュから表示、新規作成はisPending=trueで保存）
- 段階的な導入が可能（Phase 1: RemoteDataSourceのみ → Phase 2: LocalDataSource追加）
- テストが容易（RemoteとLocalを個別にモック化可能）

**明確な責務分離**:
- RemoteDataSource: HTTP通信のみ
- LocalDataSource: DB操作のみ
- Repository: 両者の調整 + キャッシュ戦略

### 2. JSONシリアライゼーションの手動実装

**現状**: 手書きの`fromJson`

```dart
// models/tag.dart (現状)
class Tag {
  Tag({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

**問題点**:
- タイポのリスク（手動でキー名を指定）
- ミュータブルなオブジェクト（バグの温床）
- `copyWith`などのメソッドを手動実装する必要
- 等価性比較が未実装

**推奨**: `freezed` + `json_serializable`でコード生成

```dart
// models/tag.dart (UIで使うシンプルなモデル)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

@freezed
class Tag with _$Tag {
  const factory Tag({
    required int id,
    required String name,
    @Default('') String description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Tag;
}

// data/models/tag_model.dart (data層で使うモデル)
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_ui/models/tag.dart';
import 'package:drift/drift.dart' as drift;

part 'tag_model.freezed.dart';
part 'tag_model.g.dart';

@freezed
class TagModel with _$TagModel {
  const TagModel._();
  
  const factory TagModel({
    required int id,
    required String name,
    @Default('') String description,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isPending,  // 同期待ちフラグ
  }) = _TagModel;
  
  factory TagModel.fromJson(Map<String, dynamic> json) => 
      _$TagModelFromJson(json);
  
  factory TagModel.fromDb(TagTableData data) {
    return TagModel(
      id: data.id,
      name: data.name,
      description: data.description,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isPending: data.isPending,
    );
  }
  
  factory TagModel.temp({required String name, required String description}) {
    final now = DateTime.now();
    return TagModel(
      id: -now.millisecondsSinceEpoch,  // 仮ID（負数）
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      isPending: true,
    );
  }
  
  TagTableCompanion toCompanion() {
    return TagTableCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      description: drift.Value(description),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      isPending: drift.Value(isPending),
    );
  }
  
  // UIで使うEntityに変換
  Tag toEntity() {
    return Tag(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

**メリット**:
- イミュータブル保証（const constructor）
- `copyWith`自動生成
- 等価性比較自動実装（`==`, `hashCode`）
- タイポ防止（コンパイル時チェック）
- `toJson`も自動生成
- Union型サポート（sealed class）

**セットアップ**:
```yaml
# pubspec.yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  build_runner: ^2.4.13  # 既に導入済み
```

**コード生成コマンド**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. API層の型安全性不足

**現状**: `String`で生JSONを返す

```dart
// api/vanilla_api.dart (現状)
class TagApiClient {
  Future<String> list() async {
    final url = Uri.parse('$baseUrl/api/v1/tags');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return utf8.decode(res.bodyBytes);  // ❌ String返却
    } else {
      throw StateError('Failure to load tags');
    }
  }
}
```

**問題点**:
- JSONパースのエラーが呼び出し側で発生
- エラーハンドリングが不統一
- 型安全性が低い

**推奨**: DataSource層で型変換を完結（Option Bの場合）

上記「Option B: DataSource分離 + Repository」のRemoteDataSourceを参照。

**メリット**:
- 型安全性の向上
- エラーハンドリングの一元化
- テストが容易（http.Clientをモック化）

### 4. 状態管理の混在

**現状**: `StateNotifier` + 新しい`@riverpod`アノテーションが混在

```dart
// state/tag_list_state.dart (現状 - StateNotifier)
class TagListNotifier extends StateNotifier<List<Tag>> {
  TagListNotifier() : super([]);
  
  Future<void> add(String name, String description) async {
    final TagApiClient apiClient = TagApiClient();
    final resBody = await apiClient.post(name, description);
    final Map<String, dynamic> decodedString = json.decode(resBody);
    final tag = Tag.fromJson(decodedString);
    state = [...state, tag];
  }
}

final tagListProvider = StateNotifierProvider<TagListNotifier, List<Tag>>(
  (ref) => TagListNotifier()
);

// state/tag_new_state.dart (現状 - @riverpod)
@riverpod
class TagNewName extends _$TagNewName {
  @override
  String build() => '';
  
  void change(String v) => state = v;
}
```

**問題点**:
- コードスタイルが統一されていない
- `StateNotifier`は冗長
- 非同期処理の扱いが複雑

**推奨**: `riverpod_generator`に統一

```dart
// providers/tag_provider.dart (推奨)
@riverpod
class TagList extends _$TagList {
  @override
  FutureOr<List<Tag>> build() async {
    return ref.watch(tagRepositoryProvider).fetchTags();
  }
  
  Future<void> add(String name, String description) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(tagRepositoryProvider).createTag(name, description);
      return ref.read(tagRepositoryProvider).fetchTags();
    });
  }
}

// フォーム用の単純な状態
@riverpod
class TagFormName extends _$TagFormName {
  @override
  String build() => '';
  
  void update(String value) => state = value;
  void clear() => state = '';
}

@riverpod
class TagFormDescription extends _$TagFormDescription {
  @override
  String build() => '';
  
  void update(String value) => state = value;
  void clear() => state = '';
}
```

**メリット**:
- コード量の削減
- 非同期処理が`AsyncValue`で統一
- 自動的に`family`や`autoDispose`が使える
- 型安全性の向上

### 5. エラーハンドリングの不足

**現状**: `StateError`のみ

```dart
// api/vanilla_api.dart (現状)
if (res.statusCode == 200) {
  return utf8.decode(res.bodyBytes);
} else {
  throw StateError('Failure to load tags');  // ❌ 汎用的すぎる
}
```

**問題点**:
- エラーの種類が区別できない
- ユーザーへのフィードバックが困難
- エラー処理の一貫性がない

**推奨**: カスタム例外 + 統一的エラー処理

```dart
// core/exceptions/api_exception.dart
sealed class ApiException implements Exception {
  const ApiException(this.message, [this.details]);
  final String message;
  final String? details;
  
  @override
  String toString() => details != null ? '$message: $details' : message;
}

class NetworkException extends ApiException {
  const NetworkException([String? details]) 
      : super('ネットワークエラーが発生しました', details);
}

class ServerException extends ApiException {
  const ServerException(this.statusCode, [String? details])
      : super('サーバーエラーが発生しました', details);
  final int statusCode;
}

class ParseException extends ApiException {
  const ParseException([String? details])
      : super('データの解析に失敗しました', details);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException()
      : super('認証が必要です');
}

// data/datasources/remote/tag_remote_datasource.dart
Future<List<TagModel>> getTags() async {
  try {
    final res = await _client.get(Uri.parse('$baseUrl/api/v1/tags'));
    
    switch (res.statusCode) {
      case 200:
        try {
          final json = jsonDecode(utf8.decode(res.bodyBytes)) as List;
          return json.map((e) => TagModel.fromJson(e)).toList();
        } catch (e) {
          throw ParseException(e.toString());
        }
      case 401:
        throw const UnauthorizedException();
      default:
        throw ServerException(res.statusCode, res.body);
    }
  } on SocketException {
    throw const NetworkException('インターネット接続を確認してください');
  } on TimeoutException {
    throw const NetworkException('接続がタイムアウトしました');
  }
}

// UI側でのエラー表示
Widget build(BuildContext context, WidgetRef ref) {
  final tagList = ref.watch(tagListProvider);
  
  return tagList.when(
    data: (tags) => TagListWidget(tags),
    loading: () => const LoadingWidget(),
    error: (error, stack) {
      final message = switch (error) {
        NetworkException() => error.message,
        ServerException() => error.message,
        UnauthorizedException() => 'ログインしてください',
        _ => '予期しないエラーが発生しました',
      };
      return ErrorWidget(message);
    },
  );
}
```

**メリット**:
- エラーの種類に応じた適切な処理
- ユーザーフレンドリーなメッセージ表示
- デバッグが容易
- Sentryなどの監視ツールと連携しやすい

## 🎯 推奨フォルダ構成

### シンプル構成（Phase 1-3）

現在の構成から段階的に移行する場合:

```
lib/
├── main.dart
├── router.dart
├── core/
│   ├── constants/
│   │   └── api_constants.dart      # baseUrlなど
│   ├── exceptions/
│   │   └── api_exception.dart      # カスタム例外
│   └── utils/
│       └── date_formatter.dart
├── models/                         # UIで使うモデル (freezed化)
│   ├── tag.dart
│   ├── tag.freezed.dart
│   ├── category.dart
│   └── calendar_event_item.dart
├── repositories/                   # 新設：Repository層
│   ├── tag_repository.dart
│   └── category_repository.dart
├── api/                            # APIクライアント（Phase 1-2で使用）
│   └── vanilla_api.dart
├── providers/                      # 状態管理を統一
│   ├── repository_provider.dart
│   ├── tag_provider.dart
│   ├── tag_provider.g.dart
│   └── theme_provider.dart
└── ui/                             # UI（変更なし）
    ├── home/
    ├── tag/
    ├── category/
    └── shared/
```

### 本格的構成（Phase 4-5、ローカルストレージ対応）

```
lib/
├── main.dart
├── router.dart
├── core/                           # 共通機能
│   ├── constants/
│   │   └── api_constants.dart
│   ├── exceptions/
│   │   └── api_exception.dart
│   └── utils/
│       └── date_utils.dart
├── data/                           # データ層
│   ├── datasources/                # データソース層
│   │   ├── remote/                 # API通信
│   │   │   ├── tag_remote_datasource.dart
│   │   │   ├── category_remote_datasource.dart
│   │   │   └── calendar_remote_datasource.dart
│   │   └── local/                  # ローカルDB
│   │       ├── tag_local_datasource.dart
│   │       ├── category_local_datasource.dart
│   │       ├── database.dart       # drift設定
│   │       └── tables/
│   │           ├── tag_table.dart
│   │           └── category_table.dart
│   ├── models/                     # data層で使うモデル (freezed)
│   │   ├── tag_model.dart
│   │   ├── tag_model.freezed.dart
│   │   ├── tag_model.g.dart
│   │   └── category_model.dart
│   └── repositories/               # Repository実装
│       ├── tag_repository.dart
│       └── category_repository.dart
├── models/                         # UIで使うモデル
│   ├── tag.dart
│   ├── tag.freezed.dart
│   ├── category.dart
│   └── calendar_event_item.dart
├── providers/                      # Riverpod providers
│   ├── datasource_provider.dart
│   ├── repository_provider.dart
│   └── tag_provider.dart
└── ui/                             # UI
    ├── home/
    │   ├── home_page.dart
    │   └── widgets/
    │       ├── home_calendar.dart
    │       └── home_event_list.dart
    ├── tag/
    │   ├── tag_page.dart
    │   └── widgets/
    │       ├── tag_list.dart
    │       └── tag_form.dart
    ├── settings/
    │   └── settings_page.dart
    └── shared/
        └── widgets/
            ├── loading_widget.dart
            ├── error_widget.dart
            └── app_divider_widget.dart
```

### Driftのテーブル定義例

```dart
// data/datasources/local/tables/tag_table.dart
import 'package:drift/drift.dart';

class TagTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isPending => boolean().withDefault(const Constant(false))();  // 同期待ち
}

// data/datasources/local/database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

@DriftDatabase(tables: [TagTable, CategoryTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'loutine.db'));
      return NativeDatabase(file);
    });
  }
}
```

## 📚 ステップアップの道筋

### Level 1: 基本構成 ✅ 完了

- ✅ go_router導入
- ✅ Riverpod導入
- ✅ 基本的なAPI通信
- ✅ riverpod_generatorの部分導入

**達成できていること**:
- ルーティングの基本実装
- 状態管理の基礎
- API通信の基本パターン

**次のステップ**: Repository層の導入

### Level 2: Repository層導入 🎯 次の目標

**目的**: ビジネスロジックとデータ取得の分離

**手順**:

1. **Repository作成**
   ```bash
   mkdir -p lib/repositories
   ```

2. **TagRepositoryの実装**
   ```dart
   // lib/repositories/tag_repository.dart
   import 'dart:convert';
   import 'package:mobile_ui/api/vanilla_api.dart';
   import 'package:mobile_ui/models/tag.dart';
   
   class TagRepository {
     final TagApiClient _apiClient;
     TagRepository(this._apiClient);
     
     Future<List<Tag>> fetchTags() async {
       final resBody = await _apiClient.list();
       final List<dynamic> json = jsonDecode(resBody);
       return json.map((e) => Tag.fromJson(e)).toList();
     }
     
     Future<Tag> createTag(String name, String description) async {
       final resBody = await _apiClient.post(name, description);
       final json = jsonDecode(resBody) as Map<String, dynamic>;
       return Tag.fromJson(json);
     }
   }
   ```

3. **Providerで提供**
   ```dart
   // lib/providers/repository_provider.dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:mobile_ui/api/vanilla_api.dart';
   import 'package:mobile_ui/repositories/tag_repository.dart';
   
   part 'repository_provider.g.dart';
   
   @riverpod
   TagApiClient tagApiClient(TagApiClientRef ref) => TagApiClient();
   
   @riverpod
   TagRepository tagRepository(TagRepositoryRef ref) {
     return TagRepository(ref.watch(tagApiClientProvider));
   }
   ```

4. **StateからRepositoryを使用**
   ```dart
   // lib/providers/tag_provider.dart
   @riverpod
   class TagList extends _$TagList {
     @override
     FutureOr<List<Tag>> build() async {
       return ref.watch(tagRepositoryProvider).fetchTags();
     }
   }
   ```

**メリット**:
- テストが書きやすくなる
- APIクライアントの変更が容易
- ビジネスロジックの再利用性向上

**所要時間**: 1-2日

### Level 3: コード生成ツール活用 🚀 中期目標

**目的**: 保守性とタイプセーフティの向上

**手順**:

1. **依存関係追加**
   ```yaml
   # pubspec.yaml
   dependencies:
     freezed_annotation: ^2.4.1
     json_annotation: ^4.8.1
   
   dev_dependencies:
     freezed: ^2.4.6
     json_serializable: ^6.7.1
   ```

2. **モデルをfreezed化**
   ```dart
   // lib/models/tag.dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   
   part 'tag.freezed.dart';
   
   @freezed
   class Tag with _$Tag {
     const factory Tag({
       required int id,
       required String name,
       @Default('') String description,
       required DateTime createdAt,
       required DateTime updatedAt,
     }) = _Tag;
   }
   ```

3. **コード生成**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **StateNotifierをriverpod_generatorに移行**
   - 既存の`StateNotifierProvider`を`@riverpod`に置き換え
   - `AsyncValue`を活用した非同期処理

**メリット**:
- イミュータブルなオブジェクト
- `copyWith`の自動生成
- タイポの防止
- コード量の削減

**所要時間**: 3-5日

### Level 4: DataSource分離 + ローカルストレージ 🏗️ 長期目標

**目的**: オフライン対応とパフォーマンス改善

**手順**:

1. **Drift導入**
   ```yaml
   # pubspec.yaml
   dependencies:
     drift: ^2.14.0
     sqlite3_flutter_libs: ^0.5.0
     path_provider: ^2.1.0
     path: ^1.8.3
     connectivity_plus: ^5.0.0
   
   dev_dependencies:
     drift_dev: ^2.14.0
   ```

2. **フォルダ構成の再編成**
   ```bash
   mkdir -p lib/data/datasources/remote
   mkdir -p lib/data/datasources/local/tables
   mkdir -p lib/data/models
   mkdir -p lib/data/repositories
   ```

3. **RemoteDataSource作成**
   - 既存のAPIクライアントをRemoteDataSourceに改名・整理
   - 型安全性向上（String返却を止めてモデル返却）

4. **LocalDataSource + Drift実装**
   - Driftのテーブル定義
   - LocalDataSource実装
   - Repositoryにキャッシュロジック追加

5. **データモデル分離**
   - `data/models/tag_model.dart` (data層用、isPendingフラグ付き)
   - `models/tag.dart` (UI層用、シンプル)
   - `toEntity()`メソッドで変換

**メリット**:
- オフライン対応
- 初回表示の高速化
- APIリクエスト削減
- 検索機能の実装が容易

**所要時間**: 2-3週間

**注意**: このレベルはオフライン対応が必要な場合のみ検討してください。

### Level 5: 高度なパターン 🎓 発展課題

**目的**: プロダクションレベルの品質

1. **Dio + Retrofit導入**
   - インターセプター（ログ、認証トークン）
   - 型安全なAPI定義
   ```dart
   @RestApi(baseUrl: "https://api.example.com")
   abstract class ApiClient {
     factory ApiClient(Dio dio) = _ApiClient;
     
     @GET("/tags")
     Future<List<Tag>> getTags();
     
     @POST("/tags")
     Future<Tag> createTag(@Body() CreateTagRequest request);
   }
   ```

2. **同期機能**
   - オフライン時の新規作成をisPending=trueで保存
   - バックグラウンド同期処理

3. **テスト充実**
   - Unit Test (mockito/mocktail)
   - Widget Test
   - Integration Test
   ```dart
   void main() {
     late TagRepository repository;
     late MockTagRemoteDataSource mockRemote;
     late MockTagLocalDataSource mockLocal;
     
     setUp(() {
       mockRemote = MockTagRemoteDataSource();
       mockLocal = MockTagLocalDataSource();
       repository = TagRepository(mockRemote, mockLocal, mockConnectivity);
     });
     
     test('fetchTags returns list of tags', () async {
       when(() => mockRemote.getTags())
           .thenAnswer((_) async => [TagModel(...)]);
       
       final tags = await repository.getTags();
       expect(tags.length, 1);
       expect(tags.first.name, 'test');
     });
   }
   ```

4. **CI/CD整備**
   - GitHub Actionsでの自動テスト
   - コードカバレッジ計測
   - 自動デプロイ

**所要時間**: 継続的な改善

## 🚀 移行パス（段階的導入）

### Phase 1: Repository層導入（1週間）
```
目標: テスタビリティの向上
- 既存のstate内APIクライアント呼び出しをRepository化
- データソース分離なし（APIクライアントをそのまま使用）
- テストの基盤整備
```

### Phase 2: riverpod_generatorへの統一（1週間）
```
目標: 状態管理の統一
- StateNotifierProviderを@riverpodに置き換え
- AsyncValueを活用した非同期処理
- コード量の削減
```

### Phase 3: Freezed導入（1-2週間）
```
目標: 型安全性の向上
- モデルを1つずつfreezed化
- toEntity()メソッド追加（将来のdata/models分離に備える）
- イミュータブル化によるバグ削減
```

### Phase 4: RemoteDataSource分離（1週間）
```
目標: データ取得の抽象化
- APIクライアントをRemoteDataSourceに改名・整理
- 型安全性向上（String返却を止めてモデル返却）
- エラーハンドリングの統一
```

### Phase 5: LocalDataSource + Drift導入（2-3週間）
```
目標: オフライン対応
- Driftセットアップ
- LocalDataSource実装
- Repositoryにキャッシュロジック追加
- data/models分離（isPendingフラグ追加）
```

### Phase 6: 同期機能（1-2週間）
```
目標: 完全なオフライン対応
- オフライン作成対応
- バックグラウンド同期
- コンフリクト解決
```

## 🔧 即座に改善できる点

### 優先度: 高 🔴

1. **Repository層の導入** (Level 2)
   - 影響範囲: 中
   - 効果: 大
   - 難易度: 低
   - 所要時間: 1-2日

2. **riverpod_generatorへの統一** (Level 3の一部)
   - `StateNotifierProvider`を`@riverpod`に置き換え
   - 影響範囲: 中
   - 効果: 中
   - 難易度: 低
   - 所要時間: 2-3日

### 優先度: 中 🟡

3. **freezedの導入** (Level 3の一部)
   - モデルを1つずつ移行
   - 影響範囲: 小（段階的に可能）
   - 効果: 中
   - 難易度: 低
   - 所要時間: 1週間

4. **カスタム例外の導入** (Level 2-3)
   - エラーハンドリングの改善
   - 影響範囲: 中
   - 効果: 中
   - 難易度: 低
   - 所要時間: 1-2日

### 優先度: 低 🟢

5. **DataSource分離 + ローカルストレージ** (Level 4)
   - オフライン対応が必要な場合のみ
   - 影響範囲: 大
   - 効果: 大（長期的）
   - 難易度: 中
   - 所要時間: 2-3週間

6. **Dio/Retrofitの導入** (Level 5)
   - APIクライアントの置き換え
   - 影響範囲: 大
   - 効果: 中
   - 難易度: 中
   - 所要時間: 1週間

## 📝 Domain層の要否に関する結論

### ❌ Domain層は不要

**理由**:

1. **EntityとModelに実質的な差がない**
   - 現在のモデルは全てAPIレスポンスの直接マッピング
   - 違いは`isPending`フラグくらい（ローカルストレージ導入時）
   - 変換処理がボイラープレートになる

2. **ビジネスルールが単純**
   ```dart
   // 現在のアプリのビジネスロジック:
   - データの取得・作成（CRUD）
   - 日付範囲でのフィルタリング
   - 複数のイベントタイプの統合表示
   
   // これらは「データ変換のロジック」であり、
   // 「ドメイン知識を必要とする複雑なルール」ではない
   ```

3. **Repository interfaceが形骸化する**
   - インターフェースと実装が1対1
   - 複数の実装を切り替える予定がない
   - 抽象化のメリットがない

**Domain層が必要になるケース**:
- 複雑なビジネスルール（予算管理、戦略パターンなど）
- 複数のデータソース統合（API + ローカルDB + キャッシュの複雑な制御）
- 外部依存の切り替え（複数のAPI実装）

**現在のプロジェクトではこれらに該当しません。**

### ✅ DataSource分離は有効（ローカルストレージ導入時）

**理由**:

1. **明確な責務分離**
   - RemoteDataSource: HTTP通信のみ
   - LocalDataSource: DB操作のみ
   - Repository: 両者の調整 + キャッシュ戦略

2. **段階的な導入が可能**
   ```dart
   // Phase 1-2: RemoteDataSourceのみ
   TagRepository(remote, null, null)
   
   // Phase 4-5: LocalDataSource追加
   TagRepository(remote, local, connectivity)
   ```

3. **テストが容易**
   - RemoteとLocalを個別にモック化
   - キャッシュ戦略のテストが書きやすい

## 📖 学習リソース

### 公式ドキュメント
- [Riverpod公式](https://riverpod.dev/)
- [Freezed](https://pub.dev/packages/freezed)
- [go_router](https://pub.dev/packages/go_router)
- [Drift](https://drift.simonbinder.eu/)

### 参考記事
- [FlutterのRepository実装例](https://codewithandrea.com/articles/flutter-repository-pattern/)
- [Riverpod + Freezedのベストプラクティス](https://codewithandrea.com/articles/flutter-state-management-riverpod/)
- [Driftによるローカルストレージ](https://drift.simonbinder.eu/docs/getting-started/)

### コミュニティ
- [Flutter日本ユーザーグループ](https://flutter-jp.connpass.com/)
- [Flutter Awesome](https://flutterawesome.com/)

## 📝 まとめ

### 現在の状態

現在のアーキテクチャは**Level 1を達成済み**で、基本的な動作は問題ありません。

### 推奨アーキテクチャ

```
✅ Repository層 → 必須（データソース調整、テスタビリティ向上）
✅ Freezed → 推奨（保守性向上、イミュータブル保証）
✅ data層のremote/local分離 → 有効（将来のオフライン対応時）
❌ domain層の導入 → 不要（オーバーエンジニアリング）
```

### 次のステップとして推奨

1. **Repository層の導入** (最優先、1-2日)
2. **riverpod_generatorへの統一** (1週間)
3. **freezedによるモデル強化** (1週間)

これらは段階的に導入可能で、既存のコードを大きく壊すことなく改善できます。

### ローカルストレージ（Level 4）の判断基準

以下のニーズがある場合に検討:
- オフラインでもデータを閲覧したい
- 初回表示を高速化したい
- ローカルDBでの検索機能が必要

小規模アプリでは**Level 2-3で十分**です。

---

**関連ドキュメント**:
- [Repository層実装ガイド](./2026-01-07-repository-layer-implementation.md)
- [Riverpodコード生成移行ガイド](./2026-01-09-riverpod-code-generation-migration.md)
- [Riverpodテスト戦略](./2026-01-09-riverpod-test-strategy.md)
