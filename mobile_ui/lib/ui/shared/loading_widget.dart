import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget(this._loading, {super.key});

  final bool _loading;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const DecoratedBox(
            decoration: BoxDecoration(color: Color(0x00000000)),
            child: Center(child: CircularProgressIndicator()),
          )
        : const SizedBox.shrink();
  }
}
