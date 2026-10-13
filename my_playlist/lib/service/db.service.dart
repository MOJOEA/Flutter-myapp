import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_playlist/models/song.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await openDatabase(
      join(await getDatabasesPath(), 'myplaylist.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE diaries('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'song TEXT NOT NULL, '
          'artist TEXT NOT NULL, '
          'content TEXT NOT NULL, '
          'date TEXT NOT NULL, '
          'type TEXT NOT NULL)',
        );

        final List<Map<String, dynamic>> mockSongs = [
          {'song': 'IN THE STARS', 'artist': 'BENSON BOONE', 'content': 'เพลงนี้พูดถึงการจากลาที่งดงาม...', 'date': '2026-09-07', 'type': 'Pop'},
          {'song': 'MY LIFE', 'artist': 'IMAGINE DRAGONS', 'content': 'เพลงร็อกจังหวะหนักแน่นที่พูดถึงชีวิต...', 'date': '2026-09-07', 'type': 'Rock'},
          {'song': "IT'S YOU", 'artist': 'ALI GATIE', 'content': 'เพลงรักซึ้งๆ ถ่ายทอดความรู้สึกอบอุ่น...', 'date': '2026-09-07', 'type': 'R&B Soul'},
          {'song': 'LET HER GO', 'artist': 'PASSENGER', 'content': 'เพลงอะคูสติกสุดคลาสสิกที่ทุกคนคุ้นเคย...', 'date': '2026-09-07', 'type': 'Acoustic / Folk'},
          {'song': 'HAPPY SONG', 'artist': 'BRING ME THE HORIZON', 'content': 'เพลงเมทัลสุดมันส์ที่เต็มไปด้วยพลังงาน...', 'date': '2026-09-07', 'type': 'Metal'},
        ];

        for (final song in mockSongs) {
          await db.insert('diaries', song);
        }
      },
    );

    return _db!;
  }

  static Future<int> insert(Song song) async {
    final db = await database;
    final data = <String, dynamic>{
      'song': song.song,
      'artist': song.artist,
      'content': song.content,
      'date': song.date,
      'type': song.type,
    };

    return db.insert('diaries', data);
  }

  static Future<List<Song>> getAll() async {
    final db = await database;
    final maps = await db.query('diaries', orderBy: 'id DESC');
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  static Future<void> delete(int id) async {
    final db = await database;
    await db.delete(
      'diaries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> update(Song song) async {
    final db = await database;

    if (song.id == null) {
      throw Exception('ไม่พบ ID ของเพลงที่ต้องการแก้ไข');
    }

    final int? id = int.tryParse(song.id!);
    if (id == null) {
      throw Exception('ID ของเพลงใน Local Database ต้องเป็นตัวเลข');
    }

    final data = <String, dynamic>{
      'song': song.song,
      'artist': song.artist,
      'content': song.content,
      'date': song.date,
      'type': song.type,
    };

    return db.update(
      'diaries',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
