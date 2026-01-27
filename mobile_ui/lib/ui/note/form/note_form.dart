import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_ui/providers/note_list_provider.dart';
import 'package:mobile_ui/providers/note_detail_provider.dart';

class NoteForm extends ConsumerStatefulWidget {
  const NoteForm({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<NoteForm> {
  final TextEditingController _titleController = TextEditingController();
  late QuillController _quillController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text;
    final delta = _quillController.document.toDelta();
    // DeltaをJSON文字列として保存（Markdown変換は後で実装）
    final content = jsonEncode(delta.toJson());

    try {
      if (widget.noteId != null) {
        // 更新
        final currentNoteAsync = ref.read(noteDetailProvider(widget.noteId!));
        final currentNote = currentNoteAsync.value;
        if (currentNote != null) {
          final updatedNote = currentNote.copyWith(
            title: title,
            content: content,
          );
          await ref.read(noteListProvider.notifier).updateNote(updatedNote);
        }
      } else {
        // 新規作成
        await ref.read(noteListProvider.notifier).createNote(
              title: title,
              content: content,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存しました')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 編集モードの場合、既存のノートデータを読み込む
    if (widget.noteId != null && !_isInitialized) {
      final noteAsync = ref.watch(noteDetailProvider(widget.noteId!));
      noteAsync.whenData((note) {
        if (note != null && !_isInitialized) {
          _titleController.text = note.title;
          try {
            // JSON文字列からDeltaを復元
            final deltaJson = jsonDecode(note.content) as List;
            final delta = Delta.fromJson(deltaJson);
            _quillController = QuillController(
              document: Document.fromDelta(delta),
              selection: const TextSelection.collapsed(offset: 0),
            );
          } catch (e) {
            // JSONのパースに失敗した場合はプレーンテキストとして表示
            _quillController.document.insert(0, note.content);
          }
          _isInitialized = true;
          if (mounted) {
            setState(() {});
          }
        }
      });
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'タイトル',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        QuillSimpleToolbar(
          controller: _quillController,
          config: const QuillSimpleToolbarConfig(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: QuillEditor.basic(
              controller: _quillController,
              config: const QuillEditorConfig(
                padding: EdgeInsets.zero,
                placeholder: 'ノートを書く...',
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('キャンセル'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveNote,
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
