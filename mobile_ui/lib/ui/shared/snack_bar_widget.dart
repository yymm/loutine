import 'package:flutter/material.dart';

SnackBar getSnackBar({required context, required text, bool error = false}) {
  return SnackBar(
    content: Text(text),
    duration: Duration(seconds: error ? 5 : 3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.only(left: 23, right: 23, bottom: 23),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: "close",
      onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    ),
    backgroundColor: error ? Colors.red : Colors.green,
  );
}
