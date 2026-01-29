import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/tag_list_provider.dart';
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
  bool _isLoading = true;
  List<DropdownItem<String>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final tags = await ref.read(tagListProvider.notifier).getList();

    final items = tags
        .map((tag) => DropdownItem(label: tag.name, value: tag.id.toString()))
        .toList();

    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  List<int> _getSelectedTagIds() {
    return _tagController.selectedItems
        .map((item) => int.parse(item.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select tags'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: double.maxFinite,
              child: MultiDropdown<String>(
                searchEnabled: true,
                controller: _tagController,
                items: _items,
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
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  Navigator.of(context).pop();
                  await widget.onSave(_getSelectedTagIds());
                },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
