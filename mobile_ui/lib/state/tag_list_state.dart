import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/tag.dart';

class TagListNotifier extends StateNotifier<List<Tag>> {
  TagListNotifier() : super([]);

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

final tagListProvider = StateNotifierProvider<TagListNotifier, List<Tag>>((ref) => TagListNotifier());

final tagListFutureProvider = FutureProvider.autoDispose<List<Tag>>((ref) async {
  return ref.read(tagListProvider.notifier).getList();
});
