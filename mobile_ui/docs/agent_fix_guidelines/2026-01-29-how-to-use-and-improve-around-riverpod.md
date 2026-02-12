 > providerの実装について質問させてください、このブランチで追加したmobile_ui/lib/providers/note_list_provider.dartは、buildを使って値を取得してinv
   alidateSelfでbuildを再度走らせて更新するスタイルで実装しています。一方でlinkやpurchaseの既存実装は明示的にgetListを実行することで取得するスタイ
   ルで実装されています。riverpodの実装としてどちらが良いのか、またどんな使い方に向いているのか、できるだけ多くの観点でメリットやデメリットを教え
   てください。

 ● 2つの実装パターンのメリット・デメリットを詳しく説明します。

   パターン1: buildで取得 + invalidateSelf（note_list_provider）

   メリット

     - 宣言的で直感的: ref.watch(noteListProvider)だけでデータ取得・キャッシュ・自動更新が完結
     - 自動キャッシング: Riverpodが初回取得後の値を保持、同じプロバイダを複数箇所で参照しても1回のAPI呼び出しで済む
     - 依存関係の自動追跡: build内で他のプロバイダをref.watchすれば、その変更時に自動再ビルド
     - 状態管理が一元化: 読み込み中(AsyncLoading)・エラー(AsyncError)などの状態をAsyncValueで一貫管理
     - Hot Reload対応: 開発時にプロバイダ定義変更でUIが自動更新される

   デメリット

     - 初期表示の制御が難しい: ウィジェットマウント時に自動でbuildが走るため、手動トリガーしたい場合は工夫が必要
     - invalidateのタイミング調整: Future.microtaskなどで非同期化しないと呼び出し元に影響する
     - パラメータ渡しが複雑: 動的パラメータが必要な場合、FamilyやAutoDisposeFamilyを使う必要がある

   パターン2: getList()で手動取得（category/tag_list_provider）

   メリット

     - 明示的な制御: いつデータを取得するか完全にコントロール可能（ボタン押下時、Pull-to-Refresh時など）
     - パラメータ渡しが簡単: メソッドの引数として自由に渡せる
     - 既存コードからの移行が容易: 従来のMVVM/MVCパターンと似た感覚で実装できる
     - ローディング状態の柔軟な管理: 手動でAsyncValue.loading()を設定するなど細かい制御が可能

   デメリット

     - キャッシュの恩恵が少ない: 毎回getList()を呼ぶと毎回API呼び出しが発生しがち
     - 状態管理が煩雑: エラーハンドリング、ローディング状態管理を自分で実装する必要がある
     - 依存関係の自動更新なし: 関連データ変更時に手動でgetList()を呼ぶ必要がある
     - コードの重複: 複数画面で同じデータが必要な場合、各画面でgetList()を呼ぶ必要がある

   使い分けの推奨

   buildパターンが向いている場合

     - 読み取り専用のマスタデータ: タグ一覧、カテゴリ一覧など頻繁に参照される静的なデータ
     - 複数画面で共有: 同じデータを複数のウィジェットで使う場合
     - リアルタイム性重視: 他の変更に応じて自動更新したい場合
     - 現在のnote_list_providerはこのパターンが適切

   getList()パターンが向いている場合

     - フォーム入力管理: link_new、purchase_newのようなユーザー入力の一時的な状態
     - 明示的な更新トリガー: Pull-to-Refresh、検索ボタンなど特定アクションでのみ取得したい場合
     - 動的パラメータが多い: 検索条件、フィルタ、ページネーションなど複雑なパラメータを扱う場合

   推奨改善案

   category/tag_list_providerをbuildパターンに変更:

     @riverpod
     class TagList extends _$TagList {
       @override
       Future<List<Tag>> build() async {
         final repository = ref.watch(tagRepositoryProvider);
         return repository.fetchTags();
       }
       
       Future<void> add(String name, String description) async {
         final repository = ref.read(tagRepositoryProvider);
         await repository.createTag(name, description);
         ref.invalidateSelf(); // 追加後に自動リフレッシュ
       }
     }

   これにより一貫性が高まり、キャッシュの恩恵も受けられます。

 > なるほど、キャッシュは大きな恩恵ですね、質問なのですがbuildパターンで、もし仮にfetchNotesする際の引数(startDateとendDate)を外から設定したい場合
   はどのような実装になるでしょうか？（検索やページネーションのような挙動を想定しています）

 ● パラメータを外から設定する場合、Riverpodでは主に3つのアプローチがあります。それぞれの実装例を示します。

   パターン1: Family を使う（最もRiverpod的）

   パラメータごとに独立したキャッシュを持つ方法です。

     // 日付範囲をパラメータとして受け取る
     class NoteDateRange {
       const NoteDateRange(this.startDate, this.endDate);
       final DateTime startDate;
       final DateTime endDate;
       
       @override
       bool operator ==(Object other) =>
         identical(this, other) ||
         other is NoteDateRange &&
         startDate == other.startDate &&
         endDate == other.endDate;
       
       @override
       int get hashCode => Object.hash(startDate, endDate);
     }
     
     @riverpod
     class NoteList extends _$NoteList {
       @override
       Future<List<Note>> build(NoteDateRange dateRange) async {
         final repository = ref.watch(noteRepositoryProvider);
         return repository.fetchNotes(dateRange.startDate, dateRange.endDate);
       }
       
       Future<void> deleteNote(int noteId) async {
         final repository = ref.read(noteRepositoryProvider);
         await repository.deleteNote(noteId);
         ref.invalidateSelf();
       }
     }
     
     // 使用例
     // 異なるパラメータで複数のキャッシュが保持される
     final notes1 = ref.watch(noteListProvider(NoteDateRange(start1, end1)));
     final notes2 = ref.watch(noteListProvider(NoteDateRange(start2, end2)));

   メリット: パラメータごとに自動キャッシュ、同じパラメータなら再利用
   デメリット: パラメータの組み合わせが多いとキャッシュが増える

   パターン2: 検索条件Providerと組み合わせる（推奨）

   検索条件を別のProviderで管理し、それをwatchする方法です。

     // 検索条件を管理するProvider
     @riverpod
     class NoteSearchCondition extends _$NoteSearchCondition {
       @override
       NoteDateRange build() {
         final now = DateTime.now();
         return NoteDateRange(
           now.subtract(const Duration(days: 365)),
           now.add(const Duration(days: 365)),
         );
       }
       
       void updateDateRange(DateTime start, DateTime end) {
         state = NoteDateRange(start, end);
       }
     }
     
     // 検索条件の変更を自動検知してリロード
     @riverpod
     class NoteList extends _$NoteList {
       @override
       Future<List<Note>> build() async {
         // 検索条件をwatch - 条件変更時に自動的にbuildが再実行される
         final dateRange = ref.watch(noteSearchConditionProvider);
         final repository = ref.watch(noteRepositoryProvider);
         return repository.fetchNotes(dateRange.startDate, dateRange.endDate);
       }
       
       Future<void> deleteNote(int noteId) async {
         final repository = ref.read(noteRepositoryProvider);
         await repository.deleteNote(noteId);
         ref.invalidateSelf();
       }
     }
     
     // 使用例
     // UIで検索条件を変更
     ref.read(noteSearchConditionProvider.notifier)
        .updateDateRange(newStart, newEnd);
     // ↑ これだけでnoteListProviderが自動的に再取得される
     
     // UIで結果を表示
     final notes = ref.watch(noteListProvider);

   メリット: 検索条件の変更だけで自動リロード、UI側がシンプル
   デメリット: グローバルな検索条件になるため、画面ごとに異なる条件が必要な場合は向かない

   パターン3: ページネーション向けの実装

   無限スクロールなどで追加読み込みする場合の実装例です。

     class NoteListState {
       const NoteListState({
         required this.notes,
         required this.hasMore,
         required this.page,
       });
       
       final List<Note> notes;
       final bool hasMore;
       final int page;
     }
     
     @riverpod
     class NoteList extends _$NoteList {
       @override
       Future<NoteListState> build() async {
         return _fetchNotes(page: 1);
       }
       
       Future<NoteListState> _fetchNotes({required int page}) async {
         final repository = ref.watch(noteRepositoryProvider);
         final notes = await repository.fetchNotesPaginated(
           page: page,
           perPage: 20,
         );
         
         return NoteListState(
           notes: notes,
           hasMore: notes.length >= 20,
           page: page,
         );
       }
       
       // 次のページを読み込む
       Future<void> loadMore() async {
         final currentState = await future; // 現在の状態を取得
         if (!currentState.hasMore) return;
         
         final nextPage = currentState.page + 1;
         final repository = ref.read(noteRepositoryProvider);
         final newNotes = await repository.fetchNotesPaginated(
           page: nextPage,
           perPage: 20,
         );
         
         state = AsyncValue.data(
           NoteListState(
             notes: [...currentState.notes, ...newNotes],
             hasMore: newNotes.length >= 20,
             page: nextPage,
           ),
         );
       }
       
       // 検索条件変更時にリセット
       Future<void> search({required DateTime start, required DateTime end}) async {
         state = const AsyncValue.loading();
         state = await AsyncValue.guard(() async {
           final repository = ref.read(noteRepositoryProvider);
           final notes = await repository.fetchNotes(start, end);
           return NoteListState(notes: notes, hasMore: false, page: 1);
         });
       }
     }

   実際のユースケースでの選択

     - 日付範囲フィルタ: パターン2（検索条件Provider）
     - 複数の独立した画面: パターン1（Family）
     - 無限スクロール: パターン3（ステート内にページ情報）
     - 複雑な検索条件: パターン2 + パターン3の組み合わせ

   検索やページネーションの場合、パターン2が最もバランスが良いです。UIで条件を変更するだけで自動的にデータが更新されるため、コードがシンプルになり
   ます。

