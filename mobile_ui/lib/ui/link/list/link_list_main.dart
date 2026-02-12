import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/ui/link/list/link_list.dart';
import 'package:mobile_ui/providers/link_list_paginated_provider.dart';

class LinkListMain extends ConsumerWidget {
  const LinkListMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Links List'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // リフレッシュボタン
              ref.read(linkListPaginatedProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'リフレッシュ',
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Expanded(child: LinkList()),
                Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    onPressed: () {
                      context.go('/link/list');
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
