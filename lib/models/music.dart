class Music {
  final int? id;
  final int userId;
  final String title;
  final String artist;
  final String album;
  final String albumArt;
  final String url;

  Music({
    this.id,
    required this.userId,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArt,
    required this.url,
  });

  Music.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userId = res["user_id"],
        title = res["title"],
        artist = res["artist"],
        album = res["album"],
        albumArt = res["album_art"],
        url = res["url"];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'artist': artist,
      'album': album,
      'album_art': albumArt,
      'url': url,
    };
  }

  Music copy({
    int? id,
    int? userId,
    String? title,
    String? artist,
    String? album,
    String? albumArt,
    String? url,
  }) {
    return Music(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      url: url ?? this.url,
    );
  }
}
