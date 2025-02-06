import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagNewNameNotifier extends Notifier<String> {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

class TagNewDescriptionNotifier extends Notifier<String> {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

final tagNewNameNotifierProvider
  = NotifierProvider<TagNewNameNotifier, String>(TagNewNameNotifier.new);

final tagNewDescriptionNotifierProvider
  = NotifierProvider<TagNewDescriptionNotifier, String>(TagNewDescriptionNotifier.new);
