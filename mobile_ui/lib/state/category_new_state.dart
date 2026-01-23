import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_new_state.g.dart';

@riverpod
class CategoryNewName extends _$CategoryNewName {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

@riverpod
class CategoryNewDescription extends _$CategoryNewDescription {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}
