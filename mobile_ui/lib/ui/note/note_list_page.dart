import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ui/providers/note_list_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

class NoteListPage extends ConsumerWidget {
  const NoteListPage({super.key});

  /// Delta JSONからプレーンテキストを抽出
  String _extractPlainText(String content) {
    try {
      final deltaJson = jsonDecode(content) as List;
      final delta = Delta.fromJson(deltaJson);
      final document = Document.fromDelta(delta);
      return document.toPlainText();
    } catch (e) {
      return content;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ノート'),
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text('ノートがありません\n下のボタンから作成してください'),
            );
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
              final plainText = _extractPlainText(note.content);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    note.title.isEmpty ? '(タイトルなし)' : note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        plainText.isEmpty
                            ? '(内容なし)'
                            : plainText.length > 100
                                ? '${plainText.substring(0, 100)}...'
                                : plainText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '更新: ${dateFormat.format(note.updatedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('削除確認'),
                          content: const Text('このノートを削除しますか？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('キャンセル'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('削除'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await ref
                            .read(noteListProvider.notifier)
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/note');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
