
import 'package:flutter/material.dart';

class AppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;

  const AppBar2({super.key, required this.onLogout});

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
        IconButton(tooltip: 'ออกจากระบบ', onPressed: onLogout, icon: const Icon(Icons.logout)),
        const SizedBox(width: 8),
      ],
    );
  }
}
