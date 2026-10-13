class Song {
  final String? id;
  final String song;
  final String artist;
  final String content;
  final String date;
  final String type;

  Song({
    this.id,
    required this.song,
    required this.artist,
    required this.content,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'song': song,
      'artist': artist,
      'content': content,
      'date': date,
      'type': type,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'] ??
        map['ID'] ??
        map['id_song'] ??
        map['song_id'] ??
        map['_id'];

    return Song(
      id: rawId?.toString(),
      song: map['song']?.toString() ?? '',
      artist: map['artist']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      type: map['type']?.toString() ?? 'Pop',
    );
  }
}
