
import 'package:flutter/material.dart';

Future<bool> confirmedDelete(BuildContext context, String song) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text('ลบเพลง?', style: TextStyle(color: Colors.white)),
          content: Text(
            'ต้องการลบ "$song" ใช่ไหม',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ??
      false;
}
