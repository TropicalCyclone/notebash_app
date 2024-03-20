class Expense {
  final int? id;
  final int userId;
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.date,
  });

  Expense.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userId = res["user_id"],
        category = res["category"],
        amount = res["amount"],
        date = DateTime.parse(res["date"]);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  Expense copy({
    int? id,
    int? userId,
    String? category,
    double? amount,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
