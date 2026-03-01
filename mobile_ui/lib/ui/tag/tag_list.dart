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
      spacing: 6,
      runSpacing: 4,
      children: tags.map((tag) {
        return Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tag,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 2),
              Text(tag.name, style: const TextStyle(fontSize: 12)),
            ],
          ),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 2),
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
