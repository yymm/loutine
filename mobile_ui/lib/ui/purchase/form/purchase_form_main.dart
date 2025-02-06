import 'package:flutter/material.dart';

class PurchaseFormMain extends StatelessWidget {
  const PurchaseFormMain({ super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Form"),
        leading: Icon(Icons.add_shopping_cart),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // context.go('/setting');
              // context.go('/text_input');
            },
            icon: const Icon(Icons.bar_chart),
          )
        ]
      ),
      body: Center(
        child: Text("purchase main"),
      )
    );
  }
}

