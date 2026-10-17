
import 'package:flutter/material.dart';
import 'package:my_playlist/models/song.dart';

import 'package:my_playlist/Util/gettype_color.dart';

class SongDetailPage extends StatelessWidget {
  final Song diary;
  const SongDetailPage({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    final typeColor = getTypeColor(diary.type);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(title: const Text('Song Detail'), backgroundColor: const Color(0xFF101010), elevation: 0, foregroundColor: Colors.white),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [typeColor.withValues(alpha: 0.85), typeColor.withValues(alpha: 0.45), const Color(0xFF080808), Colors.black],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.music_note, color: Colors.white, size: 35),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(children: [
                    Slider(value: 0.6, onChanged: (v) {}, activeColor: Colors.orange, inactiveColor: Colors.white24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.repeat, color: Colors.white, size: 20),
                        Icon(Icons.skip_previous, color: Colors.white, size: 24),
                        Icon(Icons.play_arrow, color: Colors.white, size: 30),
                        Icon(Icons.skip_next, color: Colors.white, size: 24),
                        Icon(Icons.shuffle, color: Colors.white, size: 20),
                      ],
                    ),
                  ])),
                ]),
              ),
              const SizedBox(height: 24),
              Text('${diary.song} (${diary.artist})', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text('${diary.type} Song • ${diary.date}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
              const Divider(height: 32, color: Colors.white30),
              Text(diary.content, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
