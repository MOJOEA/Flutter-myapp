import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_playlist/models/song.dart';

class ApiService {
  static const String studentId = '67011212035_song';
  static const String baseUrl =
      'https://thipwimon.comsciproject.net/mydiary/api.php/$studentId';

  static Future<void> createDiary(Song song) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'song': song.song,
        'artist': song.artist,
        'content': song.content,
        'date': song.date,
        'type': song.type,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('เพิ่มไม่สำเร็จ (${response.statusCode})');
    }
  }

  static Future<List<Song>> getDiaries() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> all = jsonDecode(response.body);
      return all.map((json) => Song.fromMap(json)).toList();
    }

    throw Exception('โหลดไม่สำเร็จ');
  }

  static Future<void> updateDiary(Song song) async {
    if (song.id == null || song.id!.isEmpty) {
      throw Exception('ไม่พบ ID ของเพลง');
    }

    final url = Uri.parse('$baseUrl/${song.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(song.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'แก้ไขบันทึกไม่สำเร็จ: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<void> deleteDiary(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception(
        'ลบบันทึกไม่สำเร็จ: ${response.statusCode} ${response.body}',
      );
    }
  }
}