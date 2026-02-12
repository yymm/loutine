import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/tag.dart';
import 'package:mobile_ui/ui/shared/loading_widget.dart';
import 'package:mobile_ui/providers/tag_list_provider.dart';

class TagList extends ConsumerWidget {
  const TagList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagListProvider);

    return SingleChildScrollView(
      child: tagsAsync.when(
        data: (tags) => TagListWidget(tags),
        error: (error, stack) => const Text('Some error happened... %error'),
        loading: () => LoadingWidget(true),
      ),
    );
  }
}

class TagListWidget extends StatelessWidget {
  const TagListWidget(this._tags, {super.key});

  final List<Tag> _tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: _tags.map((tag) {
        return Chip(avatar: Icon(Icons.tag), label: Text(tag.name));
      }).toList(),
    );
  }
}
