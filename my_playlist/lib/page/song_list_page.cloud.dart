
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_playlist/service/firebase.service.dart';

import 'package:my_playlist/Util/confirmed_delete.dart';

import 'package:my_playlist/components/appbar/appbar2.dart';
import 'package:my_playlist/components/search.dart';

import 'package:my_playlist/components/form/addItemform.dart';
import 'package:my_playlist/components/form/editIemform.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _db = FirebaseDbService.instance;
  final _picker = ImagePicker();
  XFile? _selectedImage;
  bool _saving = false;
  String _searchText = '';

  static const _background = Color(0xFF10111B);
  static const _surface = Color(0xFF1B1D2B);
  static const _primary = Color(0xFF818CF8);
  static const _secondary = Color(0xFF6366F1);

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (mounted && image != null) setState(() => _selectedImage = image);
    } catch (e, st) { debugPrint('$e\n$st'); }
  }

  Future<void> _addItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await _db.addItem(name);
      if (mounted) {
        _nameController.clear();
        setState(() => _selectedImage = null);
      }
    } catch (e, st) { debugPrint('$e\n$st'); }
    finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editItem(String documentId, String currentName) async {
    final newName = await showEditItemForm(
      context: context,
      currentName: currentName,
    );
    if (newName == null || !mounted) return;
    try {
      await _db.updateItem(documentId: documentId, name: newName);
    } catch (e, st) { debugPrint('$e\n$st'); }
  }

  Future<void> _deleteItem(String documentId, String name) async {
    if (!await confirmedDelete(context, name) || !mounted) return;
    try {
      await _db.deleteItem(documentId);
    } catch (e, st) { debugPrint('$e\n$st'); }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e, st) { debugPrint('$e\n$st'); }
  }

  Widget _buildStatus({required IconData icon, required String title, String subtitle = ''}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(24)),
            child: Icon(icon, color: _primary, size: 38),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar2(onLogout: _logout),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3730A3), Color(0xFF4F46E5), Color(0xFF312E81)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: _secondary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.cloud_done_rounded, color: Colors.white, size: 30),
                        SizedBox(width: 10),
                        Expanded(child: Text('เชื่อมต่อ Firebase สำเร็จ', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold))),
                      ]),
                      const SizedBox(height: 18),
                      Row(children: [
                        const CircleAvatar(backgroundColor: Colors.white24, 
                        child: Icon(Icons.person, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user?.email ?? 'ไม่พบอีเมลบัญชี', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('UID: ${user?.uid ?? "-"}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              AddItemForm(
                controller: _nameController,
                selectedImage: _selectedImage,
                saving: _saving,
                onSelectImage: _selectImage,
                onRemoveImage: () => setState(() => _selectedImage = null),
                onAddItem: _addItem,
              ),
              Search(
                controller: _searchController,
                searchText: _searchText,
                onChanged: (value) => setState(() => _searchText = value.trim().toLowerCase()),
                onClear: () {
                  _searchController.clear();
                  setState(() => _searchText = '');
                },
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _db.watchItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildStatus(icon: Icons.cloud_off, title: 'ไม่สามารถโหลดข้อมูลได้');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator(color: _primary)),
                    );
                  }

                  final docs = (snapshot.data?.docs ?? []).where((doc) {
                    return (doc.data()['name'] ?? '').toString().toLowerCase().contains(_searchText);
                  }).toList();

                  if (docs.isEmpty) {
                    return _buildStatus(
                      icon: _searchText.isNotEmpty ? Icons.search_off : Icons.library_music_outlined,
                      title: _searchText.isNotEmpty ? 'ไม่พบรายการที่ค้นหา' : 'ยังไม่มีรายการ',
                      subtitle: _searchText.isNotEmpty ? 'ลองค้นหาด้วยชื่ออื่น' : 'เพิ่มรายการแรกของคุณได้จากด้านบน',
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final name = doc.data()['name']?.toString() ?? 'ไม่มีชื่อ';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                          title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text('ID: ${doc.id}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ),

                          trailing: PopupMenuButton<String>(
                            tooltip: 'จัดการรายการ',
                            color: _surface,
                            icon: const Icon(Icons.more_vert, color: Colors.white70),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editItem(doc.id, name);
                              } else if (value == 'delete') {
                                _deleteItem(doc.id, name);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [
                                  Icon(Icons.edit_outlined, color: _primary),
                                  SizedBox(width: 10),
                                  Text('แก้ไข', style: TextStyle(color: Colors.white)),
                                ]),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete_outline, color: Colors.redAccent),
                                  SizedBox(width: 10),
                                  Text('ลบรายการ', style: TextStyle(color: Colors.white)),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
