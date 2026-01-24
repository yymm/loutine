import 'package:flutter/material.dart';
import 'package:mobile_ui/ui/note/form/note_form.dart';

class NoteFormMain extends StatelessWidget {
  const NoteFormMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note Form"),
        leading: Icon(Icons.note_add),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // context.go('/setting');
              // context.go('/text_input');
            },
            icon: const Icon(Icons.format_list_bulleted),
          ),
        ],
      ),
      body: SingleChildScrollView(child: Stack(children: <Widget>[NoteForm()])),
    );
  }
}
