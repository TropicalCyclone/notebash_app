class Travel {
  final int? id;
  final int userId;
  final String destination;
  final DateTime travelDate;

  Travel({
    this.id,
    required this.userId,
    required this.destination,
    required this.travelDate,
  });

  Travel.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userId = res["user_id"],
        destination = res["destination"],
        travelDate = DateTime.parse(res["travel_date"]);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'destination': destination,
      'travel_date': travelDate.toIso8601String(),
    };
  }

  Travel copy({
    int? id,
    int? userId,
    String? destination,
    DateTime? travelDate,
  }) {
    return Travel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destination: destination ?? this.destination,
      travelDate: travelDate ?? this.travelDate,
    );
  }
}
