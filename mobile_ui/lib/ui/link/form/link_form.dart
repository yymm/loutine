import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/state/link_new_state.dart';
import 'package:mobile_ui/state/tag_list_state.dart';
import 'package:mobile_ui/ui/shared/app_divider_widget.dart';
import 'package:mobile_ui/ui/shared/snack_bar_widget.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class LinkForm extends ConsumerStatefulWidget {
  const LinkForm({ super.key });

  @override
  createState() => _LinkForm();
}

class _LinkForm extends ConsumerState<LinkForm> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _tabController = MultiSelectController<String>();

  String? dropdownformfieldValue;

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final state = Provider.of<LinkFormState>(context, listen: true);
    final linkNew = ref.watch(linkNewStateProvider);
    final tags = ref.watch(tagListStateProvider);
    // final categories = ref.watch(categoryListProvider);

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
                if (!RegExp(r"^https?://[a-zA-Z0-9.a-zA-Z0-9./:!#$%&'*+-=?^_`{|}~]+$").hasMatch(value)) {
                  return 'Please enter valid url';
                }
                return null;
              },
              onChanged: (text) {
                ref.read(linkNewStateProvider.notifier).changeUrl(text);
              },
            ),
            // }}}
            SizedBox(height: 10),
            // >> Paste from clipboard {{{
            TextButton(
              onPressed: () async {
                final pastedUrl = await ref.read(linkNewStateProvider.notifier).pasteByClipBoard();
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
                ref.read(linkNewStateProvider.notifier).changeTitle(text);
              },
            ),
            // }}}
            SizedBox(height: 10),
            // >> Get title via url {{{
            TextButton(
              onPressed: () async {
                final String titleViaUrl = await ref.read(linkNewStateProvider.notifier).getTitleFromUrl();
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
            MultiDropdown(
              searchEnabled: true,
              controller: _tabController,
              chipDecoration: ChipDecoration(
                backgroundColor: Colors.teal,
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
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
              items: tags.map((tag) {
                return DropdownItem(label: tag.name, value: tag.id.toString());
              }).toList(),
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
                final tagIds = _tabController.selectedItems.map((v) => int.parse(v.value)).toList();
                // final categoryId = dropdownformfieldValue != null ? int.parse(dropdownformfieldValue!) : null;
                ref.read(linkNewStateProvider.notifier).add(tagIds: tagIds)
                  .then((v) {
                    ref.read(linkNewStateProvider.notifier).reset();
                    _urlController.value = _urlController.value.copyWith(
                      text: '',
                    );
                    _titleController.value = _titleController.value.copyWith(
                      text: '',
                    );
                    _tabController.clearAll();
                    dropdownformfieldValue = null;
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(context: context, text: 'Success to add link'));
                  })
                  .catchError((err) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(context: context, text: err.toString(), error: true));
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
