import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:my_playlist/models/random_song.dart';

class ApiService {

  static Future<RandomSong> fetchRandomSong() async {
    final genres = {
      'Pop': 'pop',
      'Rock': 'rock',
      'Metal': 'heavy metal',
      'Indie': 'indie',
      'R&B Soul': 'r&b soul',
      'EDM': 'electronic dance',
      'Jazz': 'jazz',
      'Acoustic / Folk': 'acoustic folk',
    };
    final type = genres.keys.toList()[Random().nextInt(genres.length)];
    final url = Uri.https('itunes.apple.com', '/search', {
      'term': genres[type]!,
      'media': 'music',
      'entity': 'song',
      'limit': '100',
      'country': 'th',
    });
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('โหลดเพลงไม่สำเร็จ (${response.statusCode})');
    }
    final data = jsonDecode(response.body);
    final songs = (data['results'] as List)
        .where((song) => song['trackId'] != null)
        .map((song) => RandomSong.fromJson({
              ...song as Map<String, dynamic>,
              'type': type,
            }))
        .toList();
    if (songs.isEmpty) throw Exception('ไม่พบเพลง');
    return songs[Random().nextInt(songs.length)];
  }
}
