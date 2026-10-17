
import 'package:flutter/material.dart';
import 'package:my_playlist/models/random_song.dart';

class RandomSongCard extends StatelessWidget {
  final Future<RandomSong> randomSongFuture;
  final VoidCallback onRandomize;
  final bool isSaving;
  final Future<void> Function(RandomSong song) onSave;

  const RandomSongCard({
    super.key,
    required this.randomSongFuture,
    required this.onRandomize,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RandomSong>(
      future: randomSongFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Text('โหลดเพลงไม่สำเร็จ', style: TextStyle(color: Colors.white70)),
              TextButton(onPressed: onRandomize, child: const Text('ลองอีกครั้ง')),
            ]),
          );
        }

        final song = snapshot.data!;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBB86FC).withValues(alpha: 0.3)),
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
                  child: const Icon(Icons.music_note, size: 38, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    '${song.name} (${song.type})',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(song.album, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onRandomize,
                        icon: const Icon(Icons.shuffle, size: 15),
                        label: const Text('สุ่มใหม่'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: isSaving ? null : () => onSave(song),
                        icon: const Icon(Icons.bookmark_add_rounded, size: 15),
                        label: Text(isSaving ? 'กำลังบันทึก...' : 'บันทึก'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBB86FC),
                          foregroundColor: Colors.black,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
    );
  }
}
