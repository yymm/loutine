import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/ui/link/list/link_list.dart';

class LinkListMain extends ConsumerWidget {
  const LinkListMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Links List')),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(children: [const Expanded(child: LinkList())]),
          ),
        ],
      ),
    );
  }
}
