import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08070D),
      appBar: AppBar(
        title: const Text('เกี่ยวกับ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF24113D), Color(0xFF120D20), Color(0xFF08070D), Colors.black],
            stops: [0, 0.35, 0.7, 1],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFE91E63)]),
                    boxShadow: [BoxShadow(color: const Color(0xFFE91E63).withValues(alpha: 0.35), blurRadius: 25, spreadRadius: 3)],
                  ),
                  child: const CircleAvatar(
                    radius: 52,
                    backgroundColor: Color(0xFF17131F),
                    child: Icon(Icons.library_music, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('MyPlaylist', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('แอปพลิเคชันจัดเพลย์ลิสต์เพลงส่วนตัว', style: TextStyle(fontSize: 15, color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Column(
                    children: [
                      Text('สร้างโดย นายธาดา ทองอ่อน', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      Text('รหัสนักศึกษา 67011212035', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('เวอร์ชัน 1.0', style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}