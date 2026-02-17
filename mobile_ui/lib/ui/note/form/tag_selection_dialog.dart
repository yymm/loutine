import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/tag/tag_list_provider.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

/// タグ選択ダイアログ
class TagSelectionDialog extends ConsumerStatefulWidget {
  const TagSelectionDialog({super.key, required this.onSave});

  final Future<void> Function(List<int> tagIds) onSave;

  @override
  ConsumerState<TagSelectionDialog> createState() => _TagSelectionDialogState();
}

class _TagSelectionDialogState extends ConsumerState<TagSelectionDialog> {
  final _tagController = MultiSelectController<String>();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  List<int> _getSelectedTagIds() {
    return _tagController.selectedItems
        .map((item) => int.parse(item.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagListProvider);

    return AlertDialog(
      title: const Text('Select tags'),
      content: tagsAsync.when(
        data: (tags) {
          final items = tags
              .map(
                (tag) =>
                    DropdownItem(label: tag.name, value: tag.id.toString()),
              )
              .toList();
          return SizedBox(
            width: double.maxFinite,
            child: MultiDropdown<String>(
              searchEnabled: true,
              controller: _tagController,
              items: items, // whenの中で直接変換
              chipDecoration: const ChipDecoration(
                backgroundColor: Colors.teal,
                labelStyle: TextStyle(color: Colors.white),
              ),
              fieldDecoration: const FieldDecoration(
                hintText: 'Tag',
                prefixIcon: Icon(Icons.tag),
              ),
              dropdownItemDecoration: const DropdownItemDecoration(
                selectedIcon: Icon(Icons.check_box),
                textColor: Colors.black54,
                selectedTextColor: Colors.black87,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading tags: $error')),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await widget.onSave(_getSelectedTagIds());
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
