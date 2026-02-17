import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_new_provider.g.dart';

@riverpod
class TagNewName extends _$TagNewName {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

@riverpod
class TagNewDescription extends _$TagNewDescription {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}
