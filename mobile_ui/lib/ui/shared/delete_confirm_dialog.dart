import 'package:flutter/material.dart';

/// 削除確認ダイアログを表示し、ユーザーの選択を返す
/// 
/// [context] - BuildContext
/// [title] - 削除対象のアイテムタイトル（例: "Sample Link"）
/// [itemType] - アイテムの種類（例: "Link", "Note", "Purchase"）
/// 
/// Returns: true（削除実行）/ false（キャンセル）/ null（ダイアログ外タップ）
Future<bool?> showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  String? itemType,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Are you sure you want to delete?'),
      content: Text('Title: $title'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white70,
          ),
          child: const Text('DELETE'),
        ),
      ],
    ),
  );
}
