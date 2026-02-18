import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/tag.dart';
import 'package:mobile_ui/providers/link/link_new_provider.dart';
import 'package:mobile_ui/providers/tag/tag_list_provider.dart';
import 'package:mobile_ui/ui/shared/app_divider_widget.dart';
import 'package:mobile_ui/ui/shared/snack_bar_widget.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class LinkForm extends ConsumerStatefulWidget {
  const LinkForm({super.key});

  @override
  createState() => _LinkForm();
}

class _LinkForm extends ConsumerState<LinkForm> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  MultiSelectController<String>? _tabController;
  int _previousTagCount = 0;

  String? dropdownformfieldValue;

  MultiSelectController<String> _getOrCreateController(int tagCount) {
    // タグ数が変わったら新しいコントローラーを作成
    if (_tabController == null || _previousTagCount != tagCount) {
      _tabController?.dispose();
      _tabController = MultiSelectController<String>();
      _previousTagCount = tagCount;
    }
    return _tabController!;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(linkNewProvider); // Watch provider for rebuilds
    final tagAsync = ref.watch(tagListProvider);

    // タグロード中でも空のフォームを表示
    final tags = tagAsync.hasValue ? tagAsync.value! : <Tag>[];
    final isLoading = tagAsync.isLoading;

    return Stack(
      children: [
        _buildForm(tags),
        if (isLoading)
          Positioned(
            top: 16,
            right: 16,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (tagAsync.hasError)
          Positioned(
            top: 16,
            left: 16,
            right: 48,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'タグの読み込みに失敗しました',
                style: TextStyle(color: Colors.red.shade900, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildForm(List<Tag> tags) {
    final dropdownItems = tags
        .map((tag) => DropdownItem(label: tag.name, value: tag.id.toString()))
        .toList();

    final controller = _getOrCreateController(tags.length);

    return Container(
      padding: EdgeInsets.all(25),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // >> Enter a url {{{
            TextFormField(
              controller: _urlController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Enter a url',
                labelText: 'URL',
                prefixIcon: Icon(Icons.link),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some url';
                }
                if (!RegExp(
                  r"^https?://[a-zA-Z0-9.a-zA-Z0-9./:!#$%&'*+-=?^_`{|}~]+$",
                ).hasMatch(value)) {
                  return 'Please enter valid url';
                }
                return null;
              },
              onChanged: (text) {
                ref.read(linkNewProvider.notifier).changeUrl(text);
              },
            ),
            // }}}
            SizedBox(height: 10),
            // >> Paste from clipboard {{{
            TextButton(
              onPressed: () async {
                final pastedUrl = await ref
                    .read(linkNewProvider.notifier)
                    .pasteByClipBoard();
                _urlController.value = _urlController.value.copyWith(
                  text: pastedUrl,
                );
              },
              child: Text('Paste from clipboard'),
            ),
            // }}}
            SizedBox(height: 10),
            // >> Enter a url title {{{
            TextFormField(
              controller: _titleController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Enter a url title',
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some url title';
                }
                return null;
              },
              onChanged: (text) {
                ref.read(linkNewProvider.notifier).changeTitle(text);
              },
            ),
            // }}}
            SizedBox(height: 10),
            // >> Get title via url {{{
            TextButton(
              onPressed: () async {
                final String titleViaUrl = await ref
                    .read(linkNewProvider.notifier)
                    .getTitleFromUrl();
                _titleController.value = _titleController.value.copyWith(
                  text: titleViaUrl,
                );
              },
              child: Text('Get title via url'),
            ),
            // }}}
            AppDividerWidget(),
            SizedBox(height: 20),
            // >> Tags selector {{{
            MultiDropdown<String>(
              key: ValueKey('tag_dropdown_${tags.length}'), // tagsが変わったら再構築
              searchEnabled: true,
              controller: controller,
              chipDecoration: ChipDecoration(
                backgroundColor: Colors.teal,
                labelStyle: TextStyle(color: Colors.white),
              ),
              fieldDecoration: FieldDecoration(
                hintText: 'Tag',
                prefixIcon: Icon(Icons.tag),
              ),
              dropdownItemDecoration: DropdownItemDecoration(
                selectedIcon: Icon(Icons.check_box),
                textColor: Colors.black54,
                selectedTextColor: Colors.black87,
              ),
              items: dropdownItems,
            ),
            // }}}
            SizedBox(height: 20),
            // >> Category selector {{{
            // DropdownButtonFormField(
            //   value: dropdownformfieldValue,
            //   decoration: InputDecoration(
            //     labelText: 'Category',
            //     prefixIcon: Icon(Icons.category),
            //   ),
            //   items: categories.map((category) {
            //     return DropdownMenuItem(value: category.id.toString(), child: Text(category.name));
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       dropdownformfieldValue = value;
            //     });
            //   },
            // ),
            // }}}
            SizedBox(height: 40),
            // >> Submit button {{{
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final tagIds =
                    _tabController?.selectedItems
                        .map((v) => int.parse(v.value))
                        .toList() ??
                    [];
                // final categoryId = dropdownformfieldValue != null ? int.parse(dropdownformfieldValue!) : null;
                ref
                    .read(linkNewProvider.notifier)
                    .add(tagIds: tagIds)
                    .then((v) {
                      ref.read(linkNewProvider.notifier).reset();
                      _urlController.clear();
                      _titleController.clear();
                      _tabController?.clearAll();
                      dropdownformfieldValue = null;
                      if (!context.mounted) return;
                      showSnackBar(context, text: 'Success to add link');
                    })
                    .catchError((err) {
                      if (!context.mounted) return;
                      showSnackBar(context, text: err.toString(), error: true);
                    });
              },
              style: ElevatedButton.styleFrom(fixedSize: Size(100, 100)),
              child: const Text('Submit'),
            ),
            // }}}
          ],
        ),
      ),
    );
  }
}

// vim:set foldmethod=marker:
