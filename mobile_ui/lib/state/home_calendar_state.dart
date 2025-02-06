import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/calendar_event_item.dart';
import 'package:mobile_ui/models/link.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:mobile_ui/models/purchase.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarState {
  CalendarState({
    required this.calendarEvents,
    required this.linkList,
  });
  Map<DateTime, List<CalendarEventItem>> calendarEvents;
  List<Link> linkList;
}

class CalendarStateNotifier extends StateNotifier<CalendarState> {
  CalendarStateNotifier() : super(CalendarState(calendarEvents: {}, linkList: []));

  Future<void> addLink() async {}

  Future<void> getAllEventItem(DateTime dateTime) async {
    final linkList = await getLinkList(dateTime);
    final calendarEventItemLinkList = linkList.map((link) {
      return CalendarEventItem.fromLink(link);
    }).toList();

    final purchaseList = await getPurchaseList(dateTime);
    final calendarEventItemPurchaseList = purchaseList.map((purchase) {
      return CalendarEventItem.fromPurchase(purchase);
    }).toList();

    final noteList= await getNoteList(dateTime);
    final calendarEventItemNoteList = noteList.map((note) {
      return CalendarEventItem.fromNote(note);
    }).toList();

    final calendarEventItemList = calendarEventItemLinkList + calendarEventItemPurchaseList + calendarEventItemNoteList;

    Map<DateTime, List<CalendarEventItem>> events = {};
    final _ = calendarEventItemList.map((item) {
      final dateTimeUtc = DateTime.utc(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      if (events.containsKey(dateTimeUtc)) {
        events[dateTimeUtc]!.add(item);
      } else {
        events[dateTimeUtc] = [item];
      }
    }).toList();

    state = CalendarState(calendarEvents: events, linkList: linkList);
  }

  Future<List<Link>> getLinkList(DateTime dateTime) async {
    final apiClient = LinkApiClient();
    // 月初日
    final startDate = DateTime(dateTime.year, dateTime.month, 1);
    // 月末日
    final endDate = DateTime(dateTime.year, dateTime.month + 1, 1).add(Duration(days: -1));
    final res = await apiClient.list(startDate, endDate);

    final List<dynamic> linkListJson = jsonDecode(res);
    final linkList = linkListJson.map((link) {
      return Link.fromJson(link);
    }).toList();

    return linkList;
  }

  Future<List<Purchase>> getPurchaseList(DateTime dateTime) async {
    final apiClient = PurchaseApiClient();
    // 月初日
    final startDate = DateTime(dateTime.year, dateTime.month, 1);
    // 月末日
    final endDate = DateTime(dateTime.year, dateTime.month + 1, 1).add(Duration(days: -1));
    final res = await apiClient.list(startDate, endDate);

    final List<dynamic> purchaseListJson = jsonDecode(res);
    final purchaseList = purchaseListJson.map((purchase) {
      return Purchase.fromJson(purchase);
    }).toList();

    return purchaseList;
  }

  Future<List<Note>> getNoteList(DateTime dateTime) async {
    final apiClient = NoteApiClient();
    // 月初日
    final startDate = DateTime(dateTime.year, dateTime.month, 1);
    // 月末日
    final endDate = DateTime(dateTime.year, dateTime.month + 1, 1).add(Duration(days: -1));
    final res = await apiClient.list(startDate, endDate);

    final List<dynamic> noteListJson = jsonDecode(res);
    final noteList = noteListJson.map((note) {
      return Note.fromJson(note);
    }).toList();

    return noteList;
  }
}

final calendarStateProvider
  = StateNotifierProvider<CalendarStateNotifier, CalendarState>((ref) => CalendarStateNotifier());

class CalendarFocusDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void change(DateTime v) => state = v;

  void reset() => state = DateTime.now();
}

class CalendarFormatNotifier extends Notifier<CalendarFormat> {
  @override
  CalendarFormat build() => CalendarFormat.month;

  void change(CalendarFormat v) => state = v;

  void reset() => state = CalendarFormat.month;
}

class CalendarEventListNotifier extends Notifier<List<CalendarEventItem>> {
  @override
  List<CalendarEventItem> build() => [];

  void change(List<CalendarEventItem> v) => state = v;

  void reset() => state = [];
}


final calendarFocusDayProvider
  = NotifierProvider<CalendarFocusDayNotifier, DateTime>(CalendarFocusDayNotifier.new);

final calendarFormatProvider
  = NotifierProvider<CalendarFormatNotifier, CalendarFormat>(CalendarFormatNotifier.new);

final calendarEventListProvider
  = NotifierProvider<CalendarEventListNotifier, List<CalendarEventItem>>(CalendarEventListNotifier.new);
