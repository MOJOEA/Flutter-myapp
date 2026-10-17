
import 'package:flutter/material.dart';

import 'package:my_playlist/models/song.dart';

import 'package:my_playlist/Util/gettype_color.dart';

import 'package:my_playlist/page/add_song_page.dart';
import 'package:my_playlist/page/song_detail_page.dart';

class CardSong extends StatelessWidget {
  final List<Song> diaries;
  final String? selectedSongId;
  final ValueChanged<String?> onSelected;
  final Future<void> Function(Song) onUpdate;
  final Future<void> Function(Song) onDelete;

  const CardSong({
    super.key,
    required this.diaries,
    required this.selectedSongId,
    required this.onSelected,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      itemCount: diaries.length,
      itemBuilder: (context, i) {
        final songItem = diaries[i];
        final typeColor = getTypeColor(songItem.type);
        final songId = songItem.id;
        final isSelected = selectedSongId == songId;

        return AnimatedScale(
          scale: isSelected ? 1.025 : 1,
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.change_circle, color: Colors.blue),
                    onPressed: () async {
                      try {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddSongPage(existing: songItem)),
                        );
                        if (!context.mounted) return;
                        if (result is Song) {
                          await onUpdate(result.id == null
                              ? Song(
                                  id: songItem.id,
                                  song: result.song,
                                  artist: result.artist,
                                  content: result.content,
                                  date: result.date,
                                  type: result.type,
                                )
                              : result);
                        }
                      } catch (e, st) {
                        debugPrint('แก้ไขเพลงไม่สำเร็จ: $e\n$st');
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () async {
                      try {
                        await onDelete(songItem);
                      } catch (e, st) {
                        debugPrint('ลบเพลงไม่สำเร็จ: $e\n$st');
                      }
                    },
                  ),
                ],
              ),
              onTap: () {
                if (isSelected) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SongDetailPage(diary: songItem)),
                  );
                } else {
                  onSelected(songId);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
