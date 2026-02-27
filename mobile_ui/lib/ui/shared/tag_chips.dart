import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/tag/tag_list_provider.dart';

class TagChips extends ConsumerWidget {
  const TagChips({required this.tagIds, super.key});

  final List<int> tagIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tagIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final tagsAsync = ref.watch(tagListProvider);

    return tagsAsync.when(
      data: (tags) {
        final filteredTags = tags
            .where((tag) => tagIds.contains(tag.id))
            .toList();

        if (filteredTags.isEmpty) {
          return const SizedBox.shrink();
        }

        return Wrap(
          spacing: 6,
          runSpacing: 4,
          children: filteredTags.map((tag) {
            return Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag, size: 14),
                  const SizedBox(width: 4),
                  Text(tag.name, style: const TextStyle(fontSize: 12)),
                ],
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 2),
            );
          }).toList(),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
