class Purchase {
  Purchase({
    required this.id,
    required this.title,
    required this.cost,
    required this.createdAt,
    required this.updatedAt,
    // required this.tags,
  });

  final int id;
  final String title;
  final int cost;
  final DateTime createdAt;
  final DateTime updatedAt;
  // final List<Tag> tags;

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as int,
      title: json['title'] as String,
      cost: json['cost'] as int,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
