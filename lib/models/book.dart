class Book {
  final int? id;
  final int userId;
  final String title;
  final int yearPublished;
  final String authors;

  Book({
    this.id,
    required this.userId,
    required this.title,
    required this.yearPublished,
    required this.authors,
  });

  Book.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userId = res["user_id"],
        title = res["title"],
        yearPublished = res["year_published"],
        authors = res["authors"];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'year_published': yearPublished,
      'authors': authors,
    };
  }

  Book copy({
    int? id,
    int? userId,
    String? title,
    int? yearPublished,
    String? authors,
  }) {
    return Book(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      yearPublished: yearPublished ?? this.yearPublished,
      authors: authors ?? this.authors,
    );
  }
}
