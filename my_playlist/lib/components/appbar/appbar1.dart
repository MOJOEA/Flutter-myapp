
import 'package:flutter/material.dart';

class AppBar1 extends StatelessWidget implements PreferredSizeWidget {
  final int songCount;
  final VoidCallback onRefresh;

  const AppBar1({super.key, required this.songCount, required this.onRefresh,});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('เพลงของฉัน', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('คลังเพลงส่วนตัว', style: TextStyle(color: Colors.white54, fontSize: 11)),
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
            Text('$songCount', style: const TextStyle(color: Color(0xFFBB86FC), fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'สุ่มเพลงใหม่และรีเฟรชรายการ',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: onRefresh,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
