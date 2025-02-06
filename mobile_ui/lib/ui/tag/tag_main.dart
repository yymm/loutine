import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ui/ui/shared/tag_new_widget.dart';
import 'package:mobile_ui/ui/tag/tag_list.dart';

class TagMain extends StatelessWidget {
  const TagMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag List'),
        leading: GestureDetector(
          child: const Icon(Icons.settings),
          onTap: () {
            context.go('/setting');
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.playlist_add),
                onPressed: () {
                  // >> Modal: Add new tag {{{
                  showModalBottomSheet<void>(
                    context: context,
                    isDismissible: false,
                    builder: (BuildContext context) {
                      return TagNewWidget();
                    },
                  );
                  // }}}
                },
                label: Text('Add new tag')
              ),
              SizedBox(height: 20),
              Expanded(child: TagList()),
            ],
          ),
        )
      )
    );
  }
}

// vim:set foldmethod=marker:
