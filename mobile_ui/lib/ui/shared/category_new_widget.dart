import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/state/category_list_state.dart';
import 'package:mobile_ui/state/category_new_state.dart';
import 'package:mobile_ui/ui/shared/snack_bar_widget.dart';

class CategoryNewWidget extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  CategoryNewWidget({ super.key });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryListNotifier = ref.watch(categoryListProvider.notifier);
    final categoryNewNameNotifier = ref.read<CategoryNewNameNotifier>(categoryNewNameNotifierProvider.notifier);
    final categoryNewDescriptionNotifier = ref.read<CategoryNewDescriptionNotifier>(categoryNewDescriptionNotifierProvider.notifier);

    return SizedBox(
      height: 300,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.playlist_add),
                    SizedBox(width: 10),
                    Text(
                      'Add new category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  ]
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter category title',
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some title';
                    }
                    return null;
                  },
                  onChanged: (v) {
                    categoryNewNameNotifier.change(v);
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter category desctiption',
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  onChanged: (v) {
                    categoryNewDescriptionNotifier.change(v);
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        final title = ref.read(categoryNewNameNotifierProvider);
                        final description = ref.read(categoryNewDescriptionNotifierProvider);
                        categoryListNotifier.add(title, description)
                          .then((v) {
                            categoryNewNameNotifier.reset();
                            categoryNewDescriptionNotifier.reset();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(getSnackBar(context: context, text: 'Success to add category'));
                            Navigator.pop(context);
                          })
                          .catchError((err) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(getSnackBar(context: context, text: err.toString(), error: true));
                          });
                      },
                      child: const Text('Add'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ]
                ),
              ]
            )
          )
        )
      ),
    );
  }
}
