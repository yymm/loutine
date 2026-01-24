import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ui/ui/link/form/link_form.dart';

class LinkFormMain extends StatelessWidget {
  const LinkFormMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Form'),
        leading: const Icon(Icons.add_link),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/link/list');
            },
            icon: Icon(Icons.format_list_bulleted),
          ),
        ],
      ),
      body: SingleChildScrollView(child: Stack(children: <Widget>[LinkForm()])),
    );
  }
}
