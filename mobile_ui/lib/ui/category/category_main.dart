import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ui/ui/category/category_list.dart';
import 'package:mobile_ui/ui/shared/category_new_widget.dart';

class CategoryMain extends StatelessWidget {
  const CategoryMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category List'),
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
                      return CategoryNewWidget();
                    },
                  );
                  // }}}
                },
                label: Text('Show Modal')
              ),
              SizedBox(height: 20),
              Expanded(child: CategoryList()),
            ],
          ),
        )
      )
    );
  }
}
