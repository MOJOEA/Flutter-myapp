class RandomSong {
  final int id;
  final String name;
  final String artist;
  final String album;
  final String image;
  final String? preview;
  final String? lyrics;

  RandomSong({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.image,
    this.preview,
    this.lyrics,
  });

  factory RandomSong.fromJson(Map<String, dynamic> json) => RandomSong(
    id: json['trackId'] ?? 0,
    name: json['trackName'] ?? 'ไม่ทราบชื่อเพลง',
    artist: json['artistName'] ?? 'ไม่ทราบศิลปิน',
    album: json['collectionName'] ?? 'ไม่ทราบอัลบั้ม',
    image: json['artworkUrl100'] ?? '',
    preview: json['previewUrl'],
  );

  RandomSong copyWith({String? lyrics}) => RandomSong(
    id: id,
    name: name,
    artist: artist,
    album: album,
    image: image,
    preview: preview,
    lyrics: lyrics ?? this.lyrics,
  );
}
