import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_ui/providers/note_list_provider.dart';
import 'package:mobile_ui/providers/note_detail_provider.dart';
import 'package:mobile_ui/ui/note/form/note_editor.dart';
import 'package:mobile_ui/ui/note/form/tag_selection_dialog.dart';
import 'package:mobile_ui/ui/shared/snack_bar_widget.dart';

class NoteForm extends ConsumerStatefulWidget {
  const NoteForm({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<NoteForm> {
  final _titleController = TextEditingController();
  late QuillController _quillController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _loadNoteIfEditing();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  /// 編集モードの場合、既存のノートデータを読み込む
  Future<void> _loadNoteIfEditing() async {
    if (widget.noteId == null || _isInitialized) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final noteId = int.parse(widget.noteId!);
      final noteAsync = ref.read(noteDetailProvider(noteId));
      final note = noteAsync.value;

      if (note != null && mounted && !_isInitialized) {
        _titleController.text = note.title;
        try {
          final deltaJson = jsonDecode(note.text) as List;
          final delta = Delta.fromJson(deltaJson);
          _quillController = QuillController(
            document: Document.fromDelta(delta),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } catch (e) {
          _quillController.document.insert(0, note.text);
        }
        _isInitialized = true;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<void> _showTagSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => TagSelectionDialog(
        onSave: _saveNote,
      ),
    );
  }

  Future<void> _saveNote(List<int> tagIds) async {
    if (!mounted) return;
    
    final title = _titleController.text;
    final text = _getDeltaJson();
    final notifier = ref.read(noteListProvider.notifier);

    try {
      if (widget.noteId != null) {
        await _updateNote(notifier, title, text, tagIds);
      } else {
        await _createNote(notifier, title, text, tagIds);
        // 新規作成時のみフォームクリア
        if (!mounted) return;
        _clearForm();
      }

      if (!mounted) return;
      _showSuccessMessage();
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(e);
    }
  }

  String _getDeltaJson() {
    final delta = _quillController.document.toDelta();
    return jsonEncode(delta.toJson());
  }

  Future<void> _createNote(
    dynamic notifier,
    String title,
    String text,
    List<int> tagIds,
  ) async {
    await notifier.createNote(
      title: title,
      text: text,
      tagIds: tagIds,
    );
  }

  Future<void> _updateNote(
    dynamic notifier,
    String title,
    String text,
    List<int> tagIds,
  ) async {
    final noteId = int.parse(widget.noteId!);
    final currentNoteAsync = ref.read(noteDetailProvider(noteId));
    final currentNote = currentNoteAsync.value;

    if (currentNote == null) return;
    
    final updatedNote = currentNote.copyWith(
      title: title,
      text: text,
      tagIds: tagIds,
    );
    
    await notifier.updateNote(updatedNote);
  }

  void _clearForm() {
    _titleController.clear();
    // ドキュメントを削除する代わりに、新しい空のドキュメントで置き換える
    _quillController.document = Document();
    // カーソル位置をリセット
    _quillController.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      getSnackBar(
        context: context,
        text: 'Success to save note',
      ),
    );
  }

  void _showErrorMessage(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      getSnackBar(
        context: context,
        text: error.toString(),
        error: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTitleField(),
          Expanded(
            child: NoteEditor(controller: _quillController),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTagSelectionDialog,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildTitleField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextFormField(
        controller: _titleController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          hintText: 'Enter a title',
          hintStyle: TextStyle(fontSize: 20),
          labelText: 'Title',
          labelStyle: TextStyle(fontSize: 20),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.headphones_outlined),
        ),
      ),
    );
  }
}
