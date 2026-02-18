import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/tag.dart';
import 'package:mobile_ui/ui/shared/loading_widget.dart';
import 'package:mobile_ui/providers/tag/tag_list_provider.dart';
import 'package:mobile_ui/ui/shared/delete_confirm_dialog.dart';

class TagList extends ConsumerWidget {
  const TagList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagListProvider);

    return SingleChildScrollView(
      child: tagsAsync.when(
        data: (tags) => TagListWidget(tags: tags),
        error: (error, stack) => const Text('Some error happened... %error'),
        loading: () => LoadingWidget(true),
      ),
    );
  }
}

class TagListWidget extends ConsumerWidget {
  const TagListWidget({required this.tags, super.key});

  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 10,
      children: tags.map((tag) {
        return Chip(
          avatar: const Icon(Icons.tag),
          label: Text(tag.name),
          onDeleted: () async {
            final confirm = await showDeleteConfirmDialog(
              context,
              title: tag.name,
              itemType: DeleteItemType.tag,
            );
            if (confirm == true) {
              await ref.read(tagListProvider.notifier).delete(tag.id);
            }
          },
          deleteIcon: const Icon(Icons.close, size: 18),
        );
      }).toList(),
    );
  }
}
