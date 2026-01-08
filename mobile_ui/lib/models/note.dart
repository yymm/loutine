class Note {
  Note({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    // required this.tags,
  });

  final int id;
  final String title;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  // final List<Tag> tags;

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(id: json['id'] as int, title: json['title'] as String, text: json['text'] as String, createdAt: DateTime.parse(json['created_at']), updatedAt: DateTime.parse(json['updated_at']));
  }
}
