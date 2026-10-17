class RandomSong {
  final int id;
  final String name;
  final String artist;
  final String album;
  final String image;
  final String type;
  final String? preview;

  RandomSong({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.image,
    required this.type,
    this.preview,
  });

  factory RandomSong.fromJson(Map<String, dynamic> json) => RandomSong(
        id: json['trackId'] ?? 0,
        name: json['trackName'] ?? 'ไม่ทราบชื่อเพลง',
        artist: json['artistName'] ?? 'ไม่ทราบศิลปิน',
        album: json['collectionName'] ?? 'ไม่ทราบอัลบั้ม',
        image: json['artworkUrl100'] ?? '',
        preview: json['previewUrl'],
        type: json['type'] ?? 'Pop',
      );
}