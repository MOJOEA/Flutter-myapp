
import 'package:flutter/material.dart';
import 'package:my_playlist/models/song.dart';
import 'package:my_playlist/models/random_song.dart';

import 'package:my_playlist/service/api.service.dart' as song_api;
import 'package:my_playlist/service/api.other.service.dart';

import 'package:my_playlist/page/song_detail_page.dart';
import 'package:my_playlist/page/add_song_page.dart';

import 'package:my_playlist/Util/confirmed_delete.dart';
import 'package:my_playlist/Util/gettype_color.dart';

import 'package:my_playlist/components/appbar/appbar1.dart';
import 'package:my_playlist/components/card/randomsong.dart';
import 'package:my_playlist/components/card/cardsong.dart';

class SongListAPIPage extends StatefulWidget {
  const SongListAPIPage({super.key});

  @override
  State<SongListAPIPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListAPIPage> {
  List<Song> diaries = [];
  String? _selectedSongId;
  late Future<RandomSong> _randomSongFuture;
  bool _isLoadingDiaries = true;
  bool _isSavingSong = false;

  @override
  void initState() {
    super.initState();
    _randomSongFuture = _fetchRandomSong();
    _loadSong();
  }

  Future<RandomSong> _fetchRandomSong() async {
    try {
      return await ApiService.fetchRandomSong();
    } catch (e, st) {
      debugPrint('สุ่มเพลงไม่สำเร็จ: $e\n$st');
      rethrow;
    }
  }

  Future<void> _loadSong() async {
    try {
      final data = await song_api.ApiService.getDiaries();
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

  Future<void> _addSong(Song diary) async {
    try {
      await song_api.ApiService.createDiary(diary);
      await _loadSong();
    } catch (e, st) {
      debugPrint('เพิ่มเพลงไม่สำเร็จ: $e\n$st');
    }
  }

  Future<void> _updateDiary(Song diary) async {
    if (diary.id == null || diary.id!.isEmpty) return;
    try {
      await song_api.ApiService.updateDiary(diary);
      await _loadSong();
    } catch (e, st) {
      debugPrint('แก้ไขเพลงไม่สำเร็จ: $e\n$st');
    }
  }

  Future<void> _deleteDiary(Song song) async {
    if (!await confirmedDelete(context, song.song) || !mounted || song.id == null) return;
    final id = song.id.toString();
    if (id.isEmpty) return;

    try {
      await song_api.ApiService.deleteDiary(id);
      if (!mounted) return;
      setState(() {
        if (_selectedSongId == id) _selectedSongId = null;
      });
      await _loadSong();
    } catch (e, st) {
      debugPrint('ลบเพลงไม่สำเร็จ: $e\n$st');
    }
  }

  void _randomizeSong() {
    setState(() {
      _randomSongFuture = _fetchRandomSong();
    });
  }

  Future<void> _saveRandomSong(RandomSong song) async {
    if (_isSavingSong) return;
    setState(() => _isSavingSong = true);
    try {
      await _addSong(Song(
        song: song.name,
        artist: song.artist,
        content: 'อัลบั้ม: ${song.album}',
        date: DateTime.now().toIso8601String().split('T').first,
        type: song.type,
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
      if (result is Song) await _addSong(result);
    } catch (e, st) {
      debugPrint('เปิดหน้าเพิ่มเพลงไม่สำเร็จ: $e\n$st');
    }
  }

  
@override
Widget build(BuildContext context) {
  final selectedSong = diaries.where((song) => song.id == _selectedSongId).firstOrNull;
  final themeColor = selectedSong != null ? getTypeColor(selectedSong.type) : const Color(0xFF1E1E1E);

  return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar1(
        songCount: diaries.length,
        onRefresh: () {
          _randomizeSong();
          setState(() => _isLoadingDiaries = true);
          _loadSong();
        },
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
          RandomSongCard(
            randomSongFuture: _randomSongFuture,
            onRandomize: _randomizeSong,
            isSaving: _isSavingSong,
            onSave: _saveRandomSong,
          ),
          Expanded(
            child: _isLoadingDiaries
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
                  )
                : diaries.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.library_music_outlined, size: 70, color: Colors.white38),
                            SizedBox(height: 14),
                            Text(
                              'ยังไม่มีเพลงที่บันทึก',
                              style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'กดบันทึกเพลงด้านบนเพื่อเพิ่มเพลงแรก',
                              style: TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : CardSong(
                        diaries: diaries,
                        selectedSongId: _selectedSongId,
                        onSelected: (id) => setState(() => _selectedSongId = id),
                        onUpdate: _updateDiary,
                        onDelete: _deleteDiary,
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, -5)),
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
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ),
                onPressed: _openAddSongPage,
                child: const Text(
                  'ADD TO THIS PLAYLIST',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}