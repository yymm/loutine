import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/tag.dart';
import 'package:mobile_ui/ui/shared/loading_widget.dart';
import 'package:mobile_ui/state/tag_list_state.dart';

class TagList extends ConsumerWidget {
  const TagList({ super.key });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tag>> tagList = ref.watch(tagListFutureProvider);
    final tags = ref.watch(tagListStateProvider);

    return SingleChildScrollView(
      child: switch (tagList) {
        AsyncData() => TagListWidget(tags),
        AsyncError() => const Text('Some error happened...'),
        _ => LoadingWidget(true),
      }
    );
  }
}

class TagListWidget extends StatelessWidget {
  const TagListWidget(this._tags, { super.key });

  final List<Tag> _tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: _tags.map((tag) {
        return Chip(
          avatar: Icon(Icons.tag),
          label: Text(tag.name),
        );
      }).toList()
    );
  }
}
