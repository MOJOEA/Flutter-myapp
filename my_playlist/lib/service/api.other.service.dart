import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:my_playlist/models/quote.dart';
import 'package:my_playlist/models/climate.dart';
import 'package:my_playlist/models/random_song.dart';

class ApiService {
  static Future<Quote> fetchQuote() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/quotes/random'),
    );

    if (response.statusCode == 200) {
      return Quote.fromJson(jsonDecode(response.body));
    }

    throw Exception('โหลดคำคมไม่สำเร็จ (${response.statusCode})');
  }

  static Future<Climate> fetchClimate() async {
    final response = await http.get(
      Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=13.75&longitude=100.5&current=temperature_2m',
      ),
    );

    if (response.statusCode == 200) {
      return Climate.fromJson(jsonDecode(response.body));
    }

    throw Exception('โหลดสภาพอากาศไม่สำเร็จ (${response.statusCode})');
  }

  static Future<RandomSong> fetchRandomSong({String keyword = 'pop'}) async {
    final url = Uri.https('itunes.apple.com', '/search', {
      'term': keyword,
      'media': 'music',
      'entity': 'song',
      'limit': '50',
      'country': 'th',
    });

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('โหลดเพลงไม่สำเร็จ (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final songs = (data['results'] as List)
        .where((song) => song['trackId'] != null)
        .map((song) => RandomSong.fromJson(song as Map<String, dynamic>))
        .toList();

    if (songs.isEmpty) throw Exception('ไม่พบเพลง');

    final song = songs[Random().nextInt(songs.length)];

    try {
      final lyricsUrl = Uri.https(
        'api.lyrics.ovh',
        '/v1/${Uri.encodeComponent(song.artist)}/${Uri.encodeComponent(song.name)}',
      );
      final lyricsResponse = await http.get(lyricsUrl);

      if (lyricsResponse.statusCode == 200) {
        final lyrics = jsonDecode(lyricsResponse.body)['lyrics'] as String?;
        return song.copyWith(lyrics: lyrics);
      }
    } catch (_) {}

    return song;
  }
}
