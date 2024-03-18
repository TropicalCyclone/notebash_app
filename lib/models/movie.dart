class Movie {
  final int? id;
  final int userId;
  final String title;
  final int year;
  final String genre;
  final String link;

  Movie({
    this.id,
    required this.userId,
    required this.title,
    required this.year,
    required this.genre,
    required this.link,
  });

  Movie.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userId = res["user_id"],
        title = res["title"],
        year = res["year"],
        genre = res["genre"],
        link = res["link"];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'year': year,
      'genre': genre,
      'link': link,
    };
  }

  Movie copy({
    int? id,
    int? userId,
    String? title,
    int? year,
    String? genre,
    String? link,
  }) {
    return Movie(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      link: link ?? this.link,
    );
  }
}
