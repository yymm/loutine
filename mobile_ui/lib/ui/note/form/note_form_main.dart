import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_ui/ui/note/form/note_form.dart';

class NoteFormMain extends StatelessWidget {
  const NoteFormMain({super.key, this.noteId});

  final String? noteId;

  @override
  Widget build(BuildContext context) {
    final isUpdateMode = noteId != null;
    final title = isUpdateMode ? 'Update Note #$noteId' : 'Note Form';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: const Icon(Icons.note_add),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/note/list');
            },
            icon: const Icon(Icons.format_list_bulleted),
          ),
        ],
      ),
      body: NoteForm(noteId: noteId),
    );
  }
}
