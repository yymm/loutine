import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ui/providers/note/note_list_paginated_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:mobile_ui/ui/shared/delete_confirm_dialog.dart';

class NoteListPage extends ConsumerStatefulWidget {
  const NoteListPage({super.key});

  @override
  ConsumerState<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends ConsumerState<NoteListPage> {
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
      ref.read(noteListPaginatedProvider.notifier).loadMore();
    }
  }

  /// Delta JSONからプレーンテキストを抽出
  String _extractPlainText(String text) {
    try {
      final deltaJson = jsonDecode(text) as List;
      final delta = Delta.fromJson(deltaJson);
      final document = Document.fromDelta(delta);
      return document.toPlainText();
    } catch (e) {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(noteListPaginatedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notes List')),
      body: notesAsync.when(
        data: (paginatedState) {
          if (paginatedState.items.isEmpty) {
            return const Center(child: Text('No notes here...'));
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(noteListPaginatedProvider.notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  paginatedState.items.length +
                  (paginatedState.hasMore ? 1 : 0),
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

                final note = paginatedState.items[index];
                final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
                final plainText = _extractPlainText(note.text);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      note.title.isEmpty ? '(No title...)' : note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          plainText.isEmpty
                              ? '(No content...)'
                              : plainText.length > 100
                              ? '${plainText.substring(0, 100)}...'
                              : plainText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${dateFormat.format(note.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.backspace),
                      color: Colors.black45,
                      onPressed: () async {
                        final confirm = await showDeleteConfirmDialog(
                          context,
                          title: note.title,
                          itemType: DeleteItemType.note,
                        );
                        if (confirm == true && mounted) {
                          await ref
                              .read(noteListPaginatedProvider.notifier)
                              .deleteNote(note.id);
                        }
                      },
                    ),
                    onTap: () {
                      context.push('/note/edit/${note.id}');
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
                  ref.invalidate(noteListPaginatedProvider);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
