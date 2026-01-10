import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/api/vanilla_api.dart';

part 'link_new_state.g.dart';

class LinkNew {
  LinkNew({required this.url, required this.title});

  final String url;
  final String title;
}

@riverpod
class LinkNewNotifier extends _$LinkNewNotifier {
  @override
  LinkNew build() {
    return LinkNew(url: '', title: '');
  }

  void changeUrl(String v) {
    state = LinkNew(url: v, title: state.title);
  }

  void changeTitle(String v) {
    state = LinkNew(url: state.url, title: v);
  }

  Future<String> pasteByClipBoard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    final url = clipboardData!.text ?? "";
    if (!ref.mounted) return url;
    state = LinkNew(url: url, title: state.title);
    return url;
  }

  Future<String> getTitleFromUrl() async {
    if (state.url.isEmpty) {
      return '';
    }
    final apiClient = UrlApiClient();
    final body = await apiClient.getTitleFromUrl(state.url.toString());
    final Map<String, dynamic> resJson = json.decode(body);
    // final title = faker.internet.userName();
    final title = resJson['title']!;
    if (!ref.mounted) return title;
    state = LinkNew(url: state.url, title: title);
    return title;
  }

  void reset() {
    state = LinkNew(url: '', title: '');
  }

  Future<void> add({required List<int> tagIds}) async {
    print('press add(): url => ${state.url}, ttile => ${state.title}');
    final apiClient = LinkApiClient();
    await apiClient.post(state.url, state.title, tagIds);
    return;
  }
}
