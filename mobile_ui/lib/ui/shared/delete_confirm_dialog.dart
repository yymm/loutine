import 'package:flutter/material.dart';

/// アイテムタイプの定義
enum DeleteItemType {
  link(Icons.add_link, Colors.lightBlue),
  purchase(Icons.add_shopping_cart, Colors.orange),
  note(Icons.note_add, Colors.lightGreen),
  other(Icons.delete, Colors.red);

  const DeleteItemType(this.icon, this.color);
  final IconData icon;
  final Color color;
}

/// 削除確認ダイアログを表示し、ユーザーの選択を返す
/// 
/// [context] - BuildContext
/// [title] - 削除対象のアイテムタイトル（例: "Sample Link"）
/// [itemType] - アイテムの種類（Link, Purchase, Note）
/// 
/// Returns: true（削除実行）/ false（キャンセル）/ null（ダイアログ外タップ）
Future<bool?> showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  DeleteItemType? itemType,
}) {
  final type = itemType ?? DeleteItemType.other;
  
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        type.icon,
        size: 48,
        color: type.color,
      ),
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
