import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ui/ui/link/list/link_list.dart';

class LinkListMain extends StatelessWidget {
  const LinkListMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Links List'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              return;
            },
            icon: Icon(Icons.replay_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Expanded(child: LinkList()),
                Container(
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.all(24)),
                    onPressed: () {
                      context.go('/link/list');
                    },
                    child: Icon(Icons.add),
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
