class Task {
  final int? id;
  final int userId;
  final String name;
  bool isDone;
  final DateTime dateCreated;

  Task({
    this.id,
    required this.userId,
    required this.name,
    required this.dateCreated,
    this.isDone = false,
  });

  Task.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userId = res["user_id"],
        name = res["name"],
        isDone = res["is_done"] == 1,
        dateCreated = DateTime.parse(res["date_created"]);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'is_done': isDone ? 1 : 0,
      'date_created': dateCreated.toIso8601String(),
    };
  }

  Task copy({
    int? id,
    int? userId,
    String? name,
    bool? isDone,
    DateTime? dateCreated,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
