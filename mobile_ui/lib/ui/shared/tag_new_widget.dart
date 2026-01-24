import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/tag_list_provider.dart';
import 'package:mobile_ui/providers/tag_new_provider.dart';
import 'package:mobile_ui/ui/shared/snack_bar_widget.dart';

class TagNewWidget extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  TagNewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(tagNewNameProvider);
    final description = ref.watch(tagNewDescriptionProvider);

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
                      'Add new tag',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter tag title',
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
                    ref.read(tagNewNameProvider.notifier).change(v);
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter tag desctiption',
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  onChanged: (v) {
                    ref.read(tagNewDescriptionProvider.notifier).change(v);
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        ref
                            .read(tagListProvider.notifier)
                            .add(name, description)
                            .then((v) {
                              ref.read(tagNewNameProvider.notifier).reset();
                              ref
                                  .read(tagNewDescriptionProvider.notifier)
                                  .reset();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(
                                  context: context,
                                  text: 'Success to add tag',
                                ),
                              );
                              Navigator.pop(context);
                            })
                            .catchError((err) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(
                                  context: context,
                                  text: err.toString(),
                                  error: true,
                                ),
                              );
                            });
                      },
                      child: const Text('Add'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
