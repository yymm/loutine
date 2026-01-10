import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/category.dart';
import 'package:mobile_ui/ui/shared/loading_widget.dart';
import 'package:mobile_ui/state/category_list_state.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> categoryList = ref.watch(categoryListFutureProvider);
    final categories = ref.watch(categoryListProvider);

    return SingleChildScrollView(
      child: switch (categoryList) {
        AsyncData() => CategoryListWidget(categories),
        AsyncError() => const Text('Some error happened...'),
        _ => LoadingWidget(true),
      },
    );
  }
}

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget(this._categories, {super.key});

  final List<Category> _categories;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: _categories.map((category) {
        return Card(
          margin: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(leading: Icon(Icons.category), title: Text(category.name), subtitle: Text(category.description)),
        );
      }).toList(),
    );
  }
}
