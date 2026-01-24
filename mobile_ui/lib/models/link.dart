
class Link {
  Link({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
    // required this.tags,
  });

  final int id;
  final String title;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;
  // final List<Tag> tags;

  factory Link.fromJson(Map<String, dynamic> json) {
    // final List<dynamic> tagsJson = jsonDecode(json['tags']);
    // final tags = tagsJson.map((tagJson) {
    //   return Tag.fromJson(tagJson);
    // }).toList();
    return Link(
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      // tags: tags,
    );
  }
}
