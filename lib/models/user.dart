class User {
  final int? id;
  final String username;
  final String password;

  User({this.id, required this.username, required this.password});

  User.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        username = res["username"],
        password = res["password"];

  Map<String, Object?> toMap() {
    return {'username': username, 'password': password};
  }

  String getStr() {
    return "'username': $username, 'password': $password";
  }

  User copy({int? id}) {
    return User(id: id ?? this.id, username: username, password: "");
  }
}
