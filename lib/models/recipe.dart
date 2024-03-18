class Recipe {
  final int? id;
  final int userId;
  final String name;
  final String ingredients;
  final String directions;
  final int color;

  Recipe({
    this.id,
    required this.userId,
    required this.name,
    required this.ingredients,
    required this.directions,
    required this.color,
  });

  Recipe.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userId = res["user_id"],
        name = res["name"],
        ingredients = res["ingredients"],
        directions = res["directions"],
        color = res["color"];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'ingredients': ingredients,
      'directions': directions,
      'color': color,
    };
  }

  Recipe copy({
    int? id,
    int? userId,
    String? name,
    String? ingredients,
    String? directions,
    int? color,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      directions: directions ?? this.directions,
      color: color ?? this.color,
    );
  }
}
