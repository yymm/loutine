import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/calendar_event_item.dart';
import 'package:mobile_ui/models/link.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:mobile_ui/models/purchase.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/providers/link_list_provider.dart';
import 'package:mobile_ui/providers/purchase_list_provider.dart';
import 'package:mobile_ui/providers/note_list_provider.dart';
import 'package:table_calendar/table_calendar.dart';

part 'home_calendar_provider.g.dart';

/// カレンダーに表示する月のイベント一覧を管理するProvider
///
/// buildパターンを使うことで:
/// - 同じ月のデータは自動的にキャッシュされる
/// - Link/Purchase/Noteの追加・更新時に自動的に再取得される
@riverpod
class CalendarEventData extends _$CalendarEventData {
  @override
  Future<Map<DateTime, List<CalendarEventItem>>> build(
    DateTime focusedMonth,
  ) async {
    // Link/Purchase/Noteの追加・更新・削除を検知するため空watch
    // 値は使わないが、これらのProviderが更新されたらカレンダーも再取得する
    ref.watch(linkListProvider);
    ref.watch(purchaseListProvider);
    ref.watch(noteListProvider);

    // 月初日（ローカルタイム）
    final startDate = DateTime(focusedMonth.year, focusedMonth.month, 1);
    // 月末日（ローカルタイム）
    final endDate = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);

    final linkRepo = ref.watch(linkRepositoryProvider);
    final purchaseRepo = ref.watch(purchaseRepositoryProvider);
    final noteRepo = ref.watch(noteRepositoryProvider);

    // 並列取得
    final results = await Future.wait([
      linkRepo.fetchLinks(startDate, endDate),
      purchaseRepo.fetchPurchases(startDate, endDate),
      noteRepo.fetchNotes(startDate, endDate),
    ]);

    final links = results[0] as List<Link>;
    final purchases = results[1] as List<Purchase>;
    final notes = results[2] as List<Note>;

    // CalendarEventItemに変換
    final eventItems = [
      ...links.map((e) => CalendarEventItem.fromLink(e)),
      ...purchases.map((e) => CalendarEventItem.fromPurchase(e)),
      ...notes.map((e) => CalendarEventItem.fromNote(e)),
    ];

    // 日付ごとにグルーピング
    final Map<DateTime, List<CalendarEventItem>> events = {};
    for (final item in eventItems) {
      final dateKey = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      events[dateKey] = [...(events[dateKey] ?? []), item];
    }

    return events;
  }
}

@riverpod
class CalendarFocusDay extends _$CalendarFocusDay {
  @override
  DateTime build() => DateTime.now();

  void change(DateTime v) => state = v;

  void reset() => state = DateTime.now();
}

@riverpod
class CalendarFormatManager extends _$CalendarFormatManager {
  @override
  CalendarFormat build() => CalendarFormat.month;

  void change(CalendarFormat v) => state = v;

  void reset() => state = CalendarFormat.month;
}

@riverpod
class CalendarEventList extends _$CalendarEventList {
  @override
  List<CalendarEventItem> build() => [];

  void change(List<CalendarEventItem> v) => state = v;

  void reset() => state = [];
}
