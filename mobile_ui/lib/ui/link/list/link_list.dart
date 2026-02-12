import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ui/providers/link_list_paginated_provider.dart';

class LinkList extends ConsumerStatefulWidget {
  const LinkList({super.key});

  @override
  ConsumerState<LinkList> createState() => _LinkListState();
}

class _LinkListState extends ConsumerState<LinkList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 80%スクロールしたら次のページを読み込む
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(linkListPaginatedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final linksAsync = ref.watch(linkListPaginatedProvider);

    return linksAsync.when(
      data: (paginatedState) {
        if (paginatedState.items.isEmpty) {
          return const Center(child: Text('リンクがありません\n下のボタンから追加してください'));
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(linkListPaginatedProvider.notifier).refresh(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                paginatedState.items.length + (paginatedState.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // ローディングインジケータ
              if (index == paginatedState.items.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: paginatedState.isLoadingMore
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
                );
              }

              final link = paginatedState.items[index];
              final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    link.title.isEmpty ? '(タイトルなし)' : link.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        link.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '作成: ${dateFormat.format(link.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () {
                      // TODO: ブラウザで開く機能
                    },
                  ),
                  onTap: () {
                    // TODO: 詳細画面へ
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('エラーが発生しました\n$error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(linkListPaginatedProvider);
              },
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
