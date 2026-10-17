
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddItemForm extends StatelessWidget {
  final TextEditingController controller;
  final XFile? selectedImage;
  final bool saving;
  final VoidCallback onSelectImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onAddItem;

  const AddItemForm({
    super.key,
    required this.controller,
    required this.selectedImage,
    required this.saving,
    required this.onSelectImage,
    required this.onRemoveImage,
    required this.onAddItem,
  });

  static const _background = Color(0xFF10111B);
  static const _surface = Color(0xFF1B1D2B);
  static const _primary = Color(0xFF818CF8);
  static const _secondary = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.add_circle, color: _primary),
              SizedBox(width: 8),
              Text('เพิ่มรายการใหม่', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              enabled: !saving,
              maxLength: 100,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'กรอกชื่อรายการ เช่น เพลงที่ชอบ',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.music_note, color: _primary),
                filled: true,
                fillColor: _background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) {
                if (!saving) onAddItem();
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSelectImage,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('เปิดกล้อง'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (selectedImage != null) ...[
              const SizedBox(height: 12),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(File(selectedImage!.path), width: double.infinity, height: 160, fit: BoxFit.cover),
                  ),
                  IconButton.filled(
                    tooltip: 'เอารูปออก',
                    style: IconButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white),
                    onPressed: onRemoveImage,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: saving ? null : onAddItem,
                style: FilledButton.styleFrom(
                  backgroundColor: _secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(saving ? 'กำลังบันทึก...' : 'เพิ่มข้อมูล', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
