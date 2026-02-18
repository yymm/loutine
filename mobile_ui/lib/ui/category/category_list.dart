import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/category.dart';
import 'package:mobile_ui/ui/shared/loading_widget.dart';
import 'package:mobile_ui/providers/category/category_list_provider.dart';
import 'package:mobile_ui/ui/shared/delete_confirm_dialog.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return SingleChildScrollView(
      child: categoriesAsync.when(
        data: (categories) => CategoryListWidget(categories: categories),
        loading: () => LoadingWidget(true),
        error: (error, stack) => const Text('Some error happened...'),
      ),
    );
  }
}

class CategoryListWidget extends ConsumerWidget {
  const CategoryListWidget({required this.categories, super.key});

  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 10,
      children: categories.map((category) {
        return Card(
          margin: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(Icons.category),
            title: Text(category.name),
            subtitle: Text(category.description),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: Colors.black45,
              onPressed: () async {
                final confirm = await showDeleteConfirmDialog(
                  context,
                  title: category.name,
                  itemType: DeleteItemType.category,
                );
                if (confirm == true) {
                  await ref
                      .read(categoryListProvider.notifier)
                      .delete(category.id);
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
