class Note {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String color;
  final DateTime dateCreated;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.color,
    required this.dateCreated,
  });

  Note.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userId = res["user_id"],
        title = res["title"],
        description = res["description"],
        color = res["color"],
        dateCreated = DateTime.parse(res["date_created"]);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'color': color,
      'date_created': dateCreated.toIso8601String(),
    };
  }

  String getStr() {
    return "'id': $id, 'user_id': $userId, 'title': $title, 'description': $description, 'color': $color, 'date_created': $dateCreated";
  }

  Note copy({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? color,
    DateTime? dateCreated,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
