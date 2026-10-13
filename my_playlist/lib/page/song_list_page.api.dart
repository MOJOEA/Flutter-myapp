import 'package:flutter/material.dart';
import 'package:my_playlist/models/song.dart';
import 'package:my_playlist/models/quote.dart';
import 'package:my_playlist/models/climate.dart';
import 'package:my_playlist/service/api.service.dart' as diary_api;
import 'package:my_playlist/service/api.other.service.dart';
import 'package:my_playlist/page/song_detail_page.dart';
import 'package:my_playlist/page/add_song_page.dart';

class SongListAPIPage extends StatefulWidget {
  const SongListAPIPage({super.key});

  @override
  State<SongListAPIPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListAPIPage> {
  List<Song> diaries = [];
  String? _selectedSongId;
  late Future<Quote> _quoteFuture;
  late Future<Climate> _climate;
  bool _isLoadingDiaries = true;

  @override
  void initState() {
    super.initState();
    _quoteFuture = ApiService.fetchQuote();
    _climate = ApiService.fetchClimate();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    try {
      final data = await diary_api.ApiService.getDiaries();
      if (!mounted) return;
      setState(() {
        diaries = data;
        _isLoadingDiaries = false;
        if (_selectedSongId != null &&
            !diaries.any((song) => song.id == _selectedSongId)) {
          _selectedSongId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingDiaries = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('โหลดข้อมูลเพลงไม่สำเร็จ: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _addDiary(Song diary) async {
    try {
      await diary_api.ApiService.createDiary(diary);
      await _loadDiaries();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('เพิ่มบันทึกสำเร็จ'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('เพิ่มบันทึกไม่สำเร็จ: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _updateDiary(Song diary) async {
    try {
      if (diary.id == null || diary.id!.isEmpty) {
        throw Exception('ไม่พบ ID ของเพลง กรุณาตรวจสอบข้อมูลที่ส่งกลับจากหน้าแก้ไข');
      }
      await diary_api.ApiService.updateDiary(diary);
      await _loadDiaries();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('แก้ไขบันทึกสำเร็จ'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('แก้ไขบันทึกไม่สำเร็จ: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _deleteDiary(String id) async {
    try {
      if (id.isEmpty) throw Exception('ไม่พบ ID ของเพลงที่ต้องการลบ');
      await diary_api.ApiService.deleteDiary(id);
      if (!mounted) return;
      setState(() {
        if (_selectedSongId == id) _selectedSongId = null;
      });
      await _loadDiaries();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ลบบันทึกสำเร็จ'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ลบบันทึกไม่สำเร็จ: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Pop': return Colors.blue;
      case 'Rock': return Colors.orange;
      case 'Metal': return Colors.red;
      case 'Indie': return Colors.cyan;
      case 'R&B Soul': return Colors.purple;
      case 'EDM': return Colors.grey;
      case 'Jazz': return Colors.amber;
      case 'Acoustic / Folk': return Colors.green;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSong = diaries.where((song) => song.id == _selectedSongId).firstOrNull;
    final themeColor = selectedSong != null ? _getTypeColor(selectedSong.type) : const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFBB86FC).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBB86FC).withOpacity(0.3)),
            ),
            child: const Icon(Icons.library_music_rounded, color: Color(0xFFBB86FC), size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('เพลงของฉัน', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('คลังเพลงส่วนตัว', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.normal)),
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
              border: Border.all(color: const Color(0xFFBB86FC).withOpacity(0.25)),
            ),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.music_note_rounded, color: Color(0xFFBB86FC), size: 16),
              const SizedBox(width: 4),
              Text('${diaries.length}', style: const TextStyle(color: Color(0xFFBB86FC), fontSize: 13, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'รีเฟรชข้อมูล',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _quoteFuture = ApiService.fetchQuote();
                _climate = ApiService.fetchClimate();
                _isLoadingDiaries = true;
              });
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
          FutureBuilder<Quote>(
            future: _quoteFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('โหลดคำคมไม่ได้', style: TextStyle(color: Colors.white54)),
                );
              }
              final quote = snapshot.data!;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(children: [
                  Text('"${quote.text}"', textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('— ${quote.author}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ]),
              );
            },
          ),
          FutureBuilder<Climate>(
            future: _climate,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('โหลดข้อมูลสภาพอากาศไม่ได้', style: TextStyle(color: Colors.white54)),
                );
              }
              final climate = snapshot.data!;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
                child: Text(
                  '${climate.current.temperature2m} ${climate.currentUnits.temperature2m} ${climate.current.time}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              );
            },
          ),
          Expanded(
            child: _isLoadingDiaries
                ? const Center(child: CircularProgressIndicator())
                : diaries.isEmpty
                    ? const Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.library_music_outlined, size: 70, color: Colors.white38),
                          SizedBox(height: 14),
                          Text('ยังไม่มีบันทึก', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('กดปุ่มด้านล่างเพื่อเขียนบันทึกแรก', style: TextStyle(color: Colors.white38, fontSize: 13)),
                        ]),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        itemCount: diaries.length,
                        itemBuilder: (context, i) {
                          final songItem = diaries[i];
                          final typeColor = _getTypeColor(songItem.type);
                          final isSelected = _selectedSongId == songItem.id;

                          return AnimatedScale(
                            scale: isSelected ? 1.025 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              color: const Color(0xFF202020),
                              elevation: isSelected ? 10 : 4,
                              shadowColor: isSelected ? typeColor.withValues(alpha: 0.45) : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: isSelected ? typeColor.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.05),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                leading: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: isSelected ? 52 : 46,
                                  height: isSelected ? 52 : 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: typeColor.withValues(alpha: isSelected ? 0.30 : 0.18),
                                    border: Border.all(color: typeColor.withValues(alpha: 0.65)),
                                  ),
                                  child: Icon(Icons.music_note, color: typeColor, size: isSelected ? 27 : 23),
                                ),
                                title: Text(
                                  songItem.song,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isSelected ? 16 : 15),
                                ),
                                subtitle: Text(
                                  '(${songItem.artist})\n${songItem.type} Song • ${songItem.date} • ${songItem.content}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.35),
                                ),
                                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(
                                    icon: const Icon(Icons.change_circle, color: Colors.blue),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => AddSongPage(existing: songItem)),
                                      );
                                      if (!mounted) return;
                                      if (result != null && result is Song) await _updateDiary(result);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: const Color(0xFF202020),
                                          title: const Text('ลบบันทึก?', style: TextStyle(color: Colors.white)),
                                          content: Text('ต้องการลบ "${songItem.song}" ใช่ไหม', style: const TextStyle(color: Colors.white70)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && songItem.id != null && songItem.id!.isNotEmpty) {
                                        await _deleteDiary(songItem.id!);
                                      }
                                    },
                                  ),
                                ]),
                                onTap: () {
                                  if (_selectedSongId == songItem.id) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SongDetailPage(diary: songItem)),
                                    );
                                  } else {
                                    setState(() => _selectedSongId = songItem.id);
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
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, -5))],
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
                onPressed: () async {
                  try {
                    final quote = await _quoteFuture;
                    final climate = await _climate;
                    if (!mounted) return;
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddSongPage(quote: quote, climate: climate)),
                    );
                    if (!mounted) return;
                    if (result != null && result is Song) await _addDiary(result);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('ไม่สามารถเปิดหน้าเพิ่มบันทึกได้: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
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