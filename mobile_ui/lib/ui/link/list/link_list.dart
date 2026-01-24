import 'package:flutter/material.dart';

class LinkList extends StatelessWidget {
  const LinkList({super.key});

  @override
  Widget build(BuildContext context) {
    final state = [
      {'title': 'aaa', 'url': 'hoge'},
      {'title': 'aaa', 'url': 'hoge'},
    ];
    return ListView(
      children: state.map((item) {
        final title = item['title'] ?? 'oops,,,';
        final url = item['url'] ?? 'oops,,,';
        return Card(child: Column(children: [Text(title), Text(url)]));
      }).toList(),
    );
  }
}
