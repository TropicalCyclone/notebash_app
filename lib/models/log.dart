class Log {
  int? id;
  int userId;
  DateTime logDate;

  Log({this.id, required this.userId, required this.logDate});

  Log.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userId = res["user_id"],
        logDate = DateTime.parse(res["log_date"]);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': logDate.toIso8601String(),
    };
  }

  Log copy({
    int? id,
    int? userId,
    DateTime? logDate,
  }) {
    return Log(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
    );
  }
}
