import 'package:flutter/material.dart';
import 'package:mobile_ui/ui/note/form/note_form.dart';

class NoteFormMain extends StatelessWidget {
  const NoteFormMain({super.key, this.noteId});

  final String? noteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(noteId != null ? 'ノートを編集' : '新しいノート'),
      ),
      body: NoteForm(noteId: noteId),
    );
  }
}
