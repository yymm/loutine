import 'package:flutter/material.dart';

SnackBar getSnackBar({required context, required text, bool error = false}) {
  // contextが有効な間にScaffoldMessengerの参照を取得
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  return SnackBar(
    content: Text(text),
    duration: Duration(seconds: error ? 5 : 3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.only(left: 23, right: 23, bottom: 23),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: "close",
      // 保存した参照を使用（contextは使わない）
      onPressed: () => scaffoldMessenger.hideCurrentSnackBar(),
    ),
    backgroundColor: error ? Colors.red : Colors.green,
  );
}
