import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/category.dart';
import 'package:mobile_ui/ui/shared/loading_widget.dart';
import 'package:mobile_ui/providers/category/category_list_provider.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return SingleChildScrollView(
      child: categoriesAsync.when(
        data: (categories) => CategoryListWidget(categories),
        loading: () => LoadingWidget(true),
        error: (error, stack) => const Text('Some error happened...'),
      ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(Icons.category),
            title: Text(category.name),
            subtitle: Text(category.description),
          ),
        );
      }).toList(),
    );
  }
}
