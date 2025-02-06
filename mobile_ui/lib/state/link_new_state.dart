import 'dart:convert';
import 'package:faker/faker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/api/vanilla_api.dart';

class LinkNew {
  LinkNew({
    required this.url,
    required this.title,
  });

  final String url;
  final String title;
}

class LinkNewNotifier extends StateNotifier<LinkNew> {
  LinkNewNotifier() : super(LinkNew(url: '', title: ''));

  void changeUrl(String v) {
    state = LinkNew(url: v, title: state.title);
  }

  void changeTitle(String v) {
    state = LinkNew(url: state.url, title: v);
  }

  Future<String> pasteByClipBoard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    final url = clipboardData!.text ?? "";
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
    state = LinkNew(url: state.url, title: title);
    return title;
  }

  void reset() {
    state = LinkNew(url: '', title: '');
  }

  Future<void> add({ required List<int> tagIds, int? categoryId }) async {
    print('press add(): url => ${state.url}, ttile => ${state.title}');
    final apiClient = LinkApiClient();
    await apiClient.post(state.url, state.title, tagIds, categoryId);
    return;
  }
}

final linkNewProvider = StateNotifierProvider<LinkNewNotifier, LinkNew>((ref) => LinkNewNotifier());
