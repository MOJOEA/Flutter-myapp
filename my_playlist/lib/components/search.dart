
import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  final TextEditingController controller;
  final String searchText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const Search({
    super.key,
    required this.controller,
    required this.searchText,
    required this.onChanged,
    required this.onClear,
  });

  static const _primary = Color(0xFF818CF8);
  static const _secondary = Color(0xFF6366F1);
  static const _surface = Color(0xFF1B1D2B);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        child: Row(children: [
          const Expanded(
            child: Text('รายการของฉัน', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _secondary.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('Firestore', style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'ค้นหาจากชื่อรายการ...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: _primary),
            suffixIcon: searchText.isEmpty
                ? null
                : IconButton(
                    tooltip: 'ล้างการค้นหา',
                    onPressed: onClear,
                    icon: const Icon(Icons.close, color: Colors.white60),
                  ),
            filled: true,
            fillColor: _surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
      ),
    ]);
  }
}
