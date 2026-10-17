import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const _background = Color(0xFF10111B);
const _surface = Color(0xFF1B1D2B);
const _primary = Color(0xFF818CF8);
const _secondary = Color(0xFF6366F1);

Future<String?> showEditItemForm({
  required BuildContext context,
  required String currentName,
}) async {
  final controller = TextEditingController(text: currentName);
  try {
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'แก้ไขรายการ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 100,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ชื่อรายการ',
                  labelStyle: const TextStyle(color: _primary),
                  prefixIcon: const Icon(Icons.music_note, color: _primary),
                  filled: true,
                  fillColor: _background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ImagePicker().pickImage(source: ImageSource.camera);
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('เปิดกล้อง'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FocusScope.of(dialogContext).unfocus();
              Navigator.pop(dialogContext);
            },
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.white60)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _secondary),
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                FocusScope.of(dialogContext).unfocus();
                Navigator.pop(dialogContext, value);
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('บันทึก'),
          ),
        ],
      ),
    );
  } finally {
    await Future.delayed(const Duration(milliseconds: 150));
    controller.dispose();
  }
}
