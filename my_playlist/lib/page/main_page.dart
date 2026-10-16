import 'package:flutter/material.dart';
import 'package:my_playlist/page/song_list_page.db.dart';
import 'package:my_playlist/page/song_list_page.api.dart';
import 'package:my_playlist/page/song_list_page.cloud.dart';
import 'package:my_playlist/page/about_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const Color _backgroundColor = Color(0xFF080808);
  static const Color _barColor = Color(0xFF101010);
  static const Color _primaryColor = Color(0xFFBB86FC);
  static const Color _unselectedColor = Color(0xFF777777);

  final List<Widget> _pages = [
    const SongListDBPage(),
    const SongListAPIPage(),
    const TestPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _barColor,
          border: Border(top: BorderSide(color: _primaryColor.withOpacity(0.18))),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(children: [
              _buildNavItem(0, Icons.library_music_outlined, Icons.library_music_rounded, 'บันทึก'),
              _buildNavItem(1, Icons.cloud_download_outlined, Icons.cloud_download_rounded, 'ออนไลน์'),
              _buildNavItem(2, Icons.cloud_outlined, Icons.cloud_rounded, 'Cloud'),
              _buildNavItem(3, Icons.info_outline_rounded, Icons.info_rounded, 'เกี่ยวกับ'),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor.withOpacity(0.13) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? _primaryColor.withOpacity(0.28) : Colors.transparent),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(isSelected ? selectedIcon : icon, size: isSelected ? 25 : 23, color: isSelected ? _primaryColor : _unselectedColor),
            const SizedBox(height: 5),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(
              color: isSelected ? _primaryColor : _unselectedColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 3,
              width: isSelected ? 16 : 0,
              decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(10)),
            ),
          ]),
        ),
      ),
    );
  }
}