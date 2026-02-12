import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/providers/link_list_paginated_provider.dart';

part 'link_new_provider.g.dart';

class LinkNewData {
  LinkNewData({required this.url, required this.title});

  final String url;
  final String title;
}

@riverpod
class LinkNew extends _$LinkNew {
  @override
  LinkNewData build() => LinkNewData(url: '', title: '');

  void changeUrl(String v) {
    state = LinkNewData(url: v, title: state.title);
  }

  void changeTitle(String v) {
    state = LinkNewData(url: state.url, title: v);
  }

  Future<String> pasteByClipBoard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    final url = clipboardData!.text ?? "";
    if (!ref.mounted) return url;
    state = LinkNewData(url: url, title: state.title);
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
    state = LinkNewData(url: state.url, title: title);
    return title;
  }

  void reset() {
    state = LinkNewData(url: '', title: '');
  }

  Future<void> add({required List<int> tagIds}) async {
    print('press add(): url => ${state.url}, title => ${state.title}');
    
    // LinkListPaginatedProviderのcreateメソッドを使用
    // これにより:
    // 1. リスト画面が楽観的更新される
    // 2. LinkListProviderが無効化される
    // 3. home_calendarが自動的に更新される
    await ref.read(linkListPaginatedProvider.notifier).createLink(
      state.url,
      state.title,
      tagIds,
    );
    return;
  }
}
