import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryNewNameNotifier extends Notifier<String> {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

class CategoryNewDescriptionNotifier extends Notifier<String> {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

final categoryNewNameNotifierProvider
  = NotifierProvider<CategoryNewNameNotifier, String>(CategoryNewNameNotifier.new);

final categoryNewDescriptionNotifierProvider
  = NotifierProvider<CategoryNewDescriptionNotifier, String>(CategoryNewDescriptionNotifier.new);
