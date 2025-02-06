import 'package:mobile_ui/models/category.dart';
import 'package:mobile_ui/models/link.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:mobile_ui/models/purchase.dart';
import 'package:mobile_ui/models/tag.dart';

enum CalendarEventItemType {
  link,
  purchase,
  note,
}

class CalendarEventItem {
  CalendarEventItem({
    required this.createdAt,
    required this.itemType,
    required this.id,
    required this.title,
    required this.data,
    this.tags,
    this.category,
  });

  final DateTime createdAt;
  final CalendarEventItemType itemType;
  final int id;
  final String title;
  final String data;
  final List<Tag>? tags;
  final Category? category;

  factory CalendarEventItem.fromLink(Link link) {
    return CalendarEventItem(
      createdAt: link.createdAt,
      itemType: CalendarEventItemType.link,
      id: link.id,
      title: link.title,
      data: link.url,
      // tags: link.tags,
    );
  }

  factory CalendarEventItem.fromPurchase(Purchase purchase) {
    return CalendarEventItem(
      createdAt: purchase.createdAt,
      itemType: CalendarEventItemType.purchase,
      id: purchase.id,
      title: purchase.title,
      data: purchase.cost.toString(),
      // tags: link.tags,
    );
  }

  factory CalendarEventItem.fromNote(Note note) {
    return CalendarEventItem(
      createdAt: note.createdAt,
      itemType: CalendarEventItemType.note,
      id: note.id,
      title: note.title,
      data: note.text,
      // tags: link.tags,
    );
  }
}
