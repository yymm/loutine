import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context, {
  required String text,
  bool error = false,
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: error ? 5 : 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(left: 23, right: 23, bottom: 23),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red : Colors.green,
        showCloseIcon: true,
        closeIconColor: Colors.white54,
      ),
    );
}

@Deprecated('Use showSnackBar instead')
SnackBar getSnackBar({required context, required text, bool error = false}) {
  return SnackBar(
    content: Text(text),
    duration: Duration(seconds: error ? 5 : 3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.only(left: 23, right: 23, bottom: 23),
    behavior: SnackBarBehavior.floating,
    backgroundColor: error ? Colors.red : Colors.green,
  );
}
