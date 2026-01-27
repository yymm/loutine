import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_ui/providers/note_list_provider.dart';
import 'package:mobile_ui/providers/note_detail_provider.dart';
import 'package:mobile_ui/providers/tag_list_provider.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class NoteForm extends ConsumerStatefulWidget {
  const NoteForm({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<NoteForm> {
  final TextEditingController _titleController = TextEditingController();
  late QuillController _quillController;
  final MultiSelectController<String> _tagController =
      MultiSelectController<String>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    // Fetch tags when the form is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tags = await ref.read(tagListProvider.notifier).getList();
      _tagController.setItems(
        tags
            .map(
              (tag) => DropdownItem(label: tag.name, value: tag.id.toString()),
            )
            .toList(),
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _showTagSelectionDialog() async {
    final tagController = MultiSelectController<String>();
    
    // 既存のタグを取得してコントローラーにセット
    final tags = await ref.read(tagListProvider.notifier).getList();
    tagController.setItems(
      tags
          .map(
            (tag) => DropdownItem(label: tag.name, value: tag.id.toString()),
          )
          .toList(),
    );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('タグを選択'),
          content: SizedBox(
            width: double.maxFinite,
            child: MultiDropdown<String>(
              searchEnabled: true,
              controller: tagController,
              chipDecoration: const ChipDecoration(
                backgroundColor: Colors.teal,
                labelStyle: TextStyle(color: Colors.white),
              ),
              fieldDecoration: const FieldDecoration(
                hintText: 'Tag',
                prefixIcon: Icon(Icons.tag),
              ),
              dropdownItemDecoration: const DropdownItemDecoration(
                selectedIcon: Icon(Icons.check_box),
                textColor: Colors.black54,
                selectedTextColor: Colors.black87,
              ),
              items: const [],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveNote(tagController);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNote(MultiSelectController<String> tagController) async {
    final title = _titleController.text;
    final delta = _quillController.document.toDelta();
    final content = jsonEncode(delta.toJson());
    final tagIds = tagController.selectedItems
        .map((v) => v.value)
        .toList();

    try {
      if (widget.noteId != null) {
        // 更新
        final currentNoteAsync = ref.read(noteDetailProvider(widget.noteId!));
        final currentNote = currentNoteAsync.value;
        if (currentNote != null) {
          final updatedNote = currentNote.copyWith(
            title: title,
            content: content,
            tagIds: tagIds,
          );
          await ref.read(noteListProvider.notifier).updateNote(updatedNote);
        }
      } else {
        // 新規作成
        await ref.read(noteListProvider.notifier).createNote(
              title: title,
              content: content,
              tagIds: tagIds,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存しました')),
        );
        context.go('/note/list');
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

    return Scaffold(
      body: Column(
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
          config: QuillSimpleToolbarConfig(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            // ボタンサイズとアイコンサイズの設定
            buttonOptions: const QuillSimpleToolbarButtonOptions(
              base: QuillToolbarBaseButtonOptions(
                iconSize: 18, // アイコンサイズを小さく
                iconButtonFactor: 1.2, // ボタンの余白調整
              ),
            ),
            toolbarSize: 40, // ツールバーの高さを小さく
            multiRowsDisplay: false, // 1行表示
            // Markdown対応: テキスト装飾
            showBoldButton: true, // 太字 (**text**)
            showItalicButton: true, // 斜体 (*text*)
            showUnderLineButton: false, // 下線（Markdown非対応）
            showStrikeThrough: true, // 取り消し線 (~~text~~)
            showInlineCode: true, // インラインコード (`code`)
            // 色関連（Markdown非対応）
            showColorButton: false, // 文字色
            showBackgroundColorButton: false, // 背景色
            showClearFormat: false, // 書式クリア
            // 配置（Markdown非対応）
            showAlignmentButtons: false,
            showLeftAlignment: false,
            showCenterAlignment: false,
            showRightAlignment: false,
            showJustifyAlignment: false,
            // Markdown対応: 構造
            showHeaderStyle: true, // 見出し (# ## ###)
            showListNumbers: true, // 順序付きリスト (1. 2. 3.)
            showListBullets: true, // 箇条書き (- or *)
            showListCheck: true, // チェックリスト (- [ ])
            showCodeBlock: true, // コードブロック (```)
            showQuote: true, // 引用 (>)
            showIndent: false, // インデント（リストで自動対応）
            showLink: true, // リンク ([text](url))
            // 操作
            showUndo: false, // 元に戻す
            showRedo: false, // やり直し
            // その他（非表示）
            showDirection: false, // テキスト方向
            showSearchButton: false, // 検索
            showSubscript: false, // 下付き文字
            showSuperscript: false, // 上付き文字
            showFontFamily: false, // フォント
            showFontSize: false, // フォントサイズ
            showDividers: false, // 区切り線
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTagSelectionDialog,
        child: const Icon(Icons.save),
      ),
    );
  }
}
