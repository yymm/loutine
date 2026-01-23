import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/tag.dart';

part 'tag_list_state.g.dart';

@riverpod
class TagListState extends _$TagListState {
  @override
  List<Tag> build() => [];

  Future<void> add(String name, String description) async {
    final TagApiClient apiClient = TagApiClient();
    final resBody = await apiClient.post(name, description);
    final Map<String, dynamic> decodedString = json.decode(resBody);
    final tag = Tag.fromJson(decodedString);
    state = [...state, tag];
  }

  Future<List<Tag>> getList() async {
    final TagApiClient apiClient = TagApiClient();
    final resBody = await apiClient.list();
    final List<dynamic> tagListJson= jsonDecode(resBody);
    final tagList = tagListJson.map((tag) {
      return Tag.fromJson(tag);
    }).toList();
    state = tagList;
    return tagList;
  }
}

@riverpod
Future<List<Tag>> tagListFuture(TagListFutureRef ref) async {
  return ref.read(tagListStateProvider.notifier).getList();
}
