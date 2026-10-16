import 'package:flutter/material.dart';
import 'package:my_playlist/models/song.dart';
import 'package:my_playlist/models/random_song.dart';
import 'package:my_playlist/service/db.service.dart';
import 'package:my_playlist/service/api.other.service.dart';
import 'package:my_playlist/page/song_detail_page.dart';
import 'package:my_playlist/page/add_song_page.dart';

class SongListDBPage extends StatefulWidget {
  const SongListDBPage({super.key});

  @override
  State<SongListDBPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListDBPage> {
  List<Song> diaries = [];
  String? _selectedSongId;
  late Future<RandomSong> _randomSongFuture;
  bool _isLoadingDiaries = true;
  bool _isSavingSong = false;

  @override
  void initState() {
    super.initState();
    _randomSongFuture = _fetchRandomSong();
    _loadDiaries();
  }

  Future<RandomSong> _fetchRandomSong() async {
    try {
      return await ApiService.fetchRandomSong();
    } catch (e, st) {
      debugPrint('สุ่มเพลงไม่สำเร็จ: $e\n$st');
      rethrow;
    }
  }

  Future<void> _loadDiaries() async {
    try {
      final data = await DatabaseHelper.getAll();
      if (!mounted) return;
      setState(() {
        diaries = data;
        _isLoadingDiaries = false;
        if (_selectedSongId != null &&
            !diaries.any((song) => song.id == _selectedSongId)) {
          _selectedSongId = null;
        }
      });
    } catch (e, st) {
      debugPrint('โหลดรายการเพลงไม่สำเร็จ: $e\n$st');
      if (mounted) setState(() => _isLoadingDiaries = false);
    }
  }

  Future<void> _addDiary(Song diary) async {
    await DatabaseHelper.insert(diary);
    await _loadDiaries();
  }

  Future<void> _updateDiary(Song diary) async {
    if (diary.id == null) return;
    await DatabaseHelper.update(diary);
    await _loadDiaries();
  }

  Future<void> _deleteDiary(Song diary) async {
    if (diary.id == null) return;
    final id = int.tryParse(diary.id.toString());
    if (id == null) return;
    await DatabaseHelper.delete(id);
    if (!mounted) return;
    setState(() {
      if (_selectedSongId == diary.id) _selectedSongId = null;
    });
    await _loadDiaries();
  }

  void _randomizeSong() {
    setState(() => _randomSongFuture = _fetchRandomSong());
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Pop':
        return Colors.blue;
      case 'Rock':
        return Colors.orange;
      case 'Metal':
        return Colors.red;
      case 'Indie':
        return Colors.cyan;
      case 'R&B Soul':
        return Colors.purple;
      case 'EDM':
        return Colors.grey;
      case 'Jazz':
        return Colors.amber;
      case 'Acoustic / Folk':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Future<void> _saveRandomSong(RandomSong song) async {
    if (_isSavingSong) return;
    setState(() => _isSavingSong = true);

    try {
      await _addDiary(Song(
        song: song.name,
        artist: song.artist,
        content: song.lyrics?.isNotEmpty == true
            ? song.lyrics!
            : 'อัลบั้ม: ${song.album}',
        date: DateTime.now().toIso8601String().split('T').first,
        type: 'Pop',
      ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกเพลงเรียบร้อยแล้ว')),
      );
    } catch (e, st) {
      debugPrint('บันทึกเพลงไม่สำเร็จ: $e\n$st');
    } finally {
      if (mounted) setState(() => _isSavingSong = false);
    }
  }

  Future<void> _openAddSongPage() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddSongPage()),
      );
      if (!mounted) return;
      if (result is Song) await _addDiary(result);
    } catch (e, st) {
      debugPrint('เปิดหน้าเพิ่มเพลงไม่สำเร็จ: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSong =
        diaries.where((song) => song.id == _selectedSongId).firstOrNull;
    final themeColor = selectedSong != null
        ? _getTypeColor(selectedSong.type)
        : const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFBB86FC).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBB86FC).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.library_music_rounded,
              color: Color(0xFFBB86FC),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'เพลงของฉัน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'คลังเพลงส่วนตัว',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ]),
        backgroundColor: const Color(0xFF101010),
        elevation: 8,
        shadowColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFBB86FC).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFBB86FC).withOpacity(0.25),
              ),
            ),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(
                Icons.music_note_rounded,
                color: Color(0xFFBB86FC),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${diaries.length}',
                style: const TextStyle(
                  color: Color(0xFFBB86FC),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'สุ่มเพลงใหม่และรีเฟรชรายการ',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _randomizeSong();
              setState(() => _isLoadingDiaries = true);
              _loadDiaries();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeColor.withValues(alpha: 0.85),
              themeColor.withValues(alpha: 0.40),
              const Color(0xFF080808),
              Colors.black,
            ],
            stops: const [0.0, 0.28, 0.68, 1.0],
          ),
        ),
        child: Column(children: [
          FutureBuilder<RandomSong>(
            future: _randomSongFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFBB86FC),
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final song = snapshot.data!;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFBB86FC).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      song.image,
                      width: 82,
                      height: 82,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => Container(
                        width: 82,
                        height: 82,
                        color: const Color(0xFF292929),
                        child: const Icon(
                          Icons.music_note,
                          size: 38,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFBB86FC),
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'สุ่มเพลงสำหรับคุณ',
                            style: TextStyle(
                              color: Color(0xFFBB86FC),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 5),
                        Text(
                          song.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          song.album,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _randomizeSong,
                              icon: const Icon(Icons.shuffle, size: 15),
                              label: const Text('สุ่มใหม่'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isSavingSong
                                  ? null
                                  : () => _saveRandomSong(song),
                              icon: const Icon(
                                Icons.bookmark_add_rounded,
                                size: 15,
                              ),
                              label: Text(
                                _isSavingSong ? 'กำลังบันทึก...' : 'บันทึก',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFBB86FC),
                                foregroundColor: Colors.black,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              );
            },
          ),
          Expanded(
            child: _isLoadingDiaries
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFBB86FC),
                    ),
                  )
                : diaries.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_music_outlined,
                              size: 70,
                              color: Colors.white38,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'ยังไม่มีเพลงที่บันทึก',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'กดบันทึกเพลงด้านบนเพื่อเพิ่มเพลงแรก',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        itemCount: diaries.length,
                        itemBuilder: (context, i) {
                          final songItem = diaries[i];
                          final typeColor = _getTypeColor(songItem.type);
                          final songId = songItem.id;
                          final isSelected = _selectedSongId == songId;

                          return AnimatedScale(
                            scale: isSelected ? 1.025 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              color: const Color(0xFF202020),
                              elevation: isSelected ? 10 : 4,
                              shadowColor: isSelected
                                  ? typeColor.withValues(alpha: 0.45)
                                  : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: isSelected
                                      ? typeColor.withValues(alpha: 0.9)
                                      : Colors.white.withValues(alpha: 0.05),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                leading: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: isSelected ? 52 : 46,
                                  height: isSelected ? 52 : 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: typeColor.withValues(
                                      alpha: isSelected ? 0.30 : 0.18,
                                    ),
                                    border: Border.all(
                                      color: typeColor.withValues(alpha: 0.65),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.music_note,
                                    color: typeColor,
                                    size: isSelected ? 27 : 23,
                                  ),
                                ),
                                title: Text(
                                  songItem.song,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSelected ? 16 : 15,
                                  ),
                                ),
                                subtitle: Text(
                                  '(${songItem.artist})\n${songItem.type} Song • ${songItem.date} • ${songItem.content}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.change_circle,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        try {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddSongPage(existing: songItem),
                                            ),
                                          );
                                          if (!mounted) return;
                                          if (result is Song) {
                                            final updatedSong = result.id == null
                                                ? Song(
                                                    id: songItem.id,
                                                    song: result.song,
                                                    artist: result.artist,
                                                    content: result.content,
                                                    date: result.date,
                                                    type: result.type,
                                                  )
                                                : result;
                                            await _updateDiary(updatedSong);
                                          }
                                        } catch (e, st) {
                                          debugPrint('แก้ไขเพลงไม่สำเร็จ: $e\n$st');
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor:
                                                const Color(0xFF202020),
                                            title: const Text(
                                              'ลบเพลง?',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            content: Text(
                                              'ต้องการลบ "${songItem.song}" ใช่ไหม',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('ยกเลิก'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text(
                                                  'ลบ',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            await _deleteDiary(songItem);
                                          } catch (e, st) {
                                            debugPrint('ลบเพลงไม่สำเร็จ: $e\n$st');
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  if (_selectedSongId == songId) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SongDetailPage(diary: songItem),
                                      ),
                                    );
                                  } else {
                                    setState(() => _selectedSongId = songId);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 15,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF292929),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                onPressed: _openAddSongPage,
                child: const Text(
                  'ADD TO THIS PLAYLIST',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
