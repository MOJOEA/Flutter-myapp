import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../service/firebase.service.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseDbService _db = FirebaseDbService.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  bool _saving = false;
  String _searchText = '';

  static const Color _background = Color(0xFF10111B);
  static const Color _surface = Color(0xFF1B1D2B);
  static const Color _primary = Color(0xFF818CF8);
  static const Color _secondary = Color(0xFF6366F1);

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      return await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );
    } catch (e) {
      if (mounted) {
        _showMessage('ไม่สามารถเลือกรูปภาพได้: $e', isError: true);
      }
      return null;
    }
  }

  Future<void> _selectImage(ImageSource source) async {
    final image = await _pickImage(source);
    if (!mounted || image == null) return;
    setState(() => _selectedImage = image);
  }

  Future<String> _uploadImage(XFile image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('กรุณาเข้าสู่ระบบก่อนอัปโหลดรูป');
    }
    final fileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('users/${user.uid}/covers/$fileName');
    await ref.putFile(File(image.path), SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<void> _deleteStorageImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (_) {}
  }

  Widget _imagePickerButtons({required VoidCallback onCamera}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('เปิดกล้อง'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('กรุณากรอกชื่อรายการ', isError: true);
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    String? uploadedUrl;
    try {
      if (_selectedImage != null) {
        uploadedUrl = await _uploadImage(_selectedImage!);
      }
      await _db.addItem(name, imageUrl: uploadedUrl);
      if (!mounted) return;
      setState(() {
        _nameController.clear();
        _selectedImage = null;
      });
      _showMessage('เพิ่มรายการสำเร็จ');
    } catch (e) {
      await _deleteStorageImage(uploadedUrl);
      if (!mounted) return;
      _showMessage('เพิ่มรายการไม่สำเร็จ: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _editItem({
    required String documentId,
    required String currentName,
    required String? currentImageUrl,
  }) async {
    final controller = TextEditingController(text: currentName);
    XFile? replacementImage;
    String? newName;

    try {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 180,
                          height: 130,
                          child: replacementImage != null
                              ? Image.file(File(replacementImage!.path), fit: BoxFit.cover)
                              : (currentImageUrl != null && currentImageUrl.isNotEmpty)
                                  ? Image.network(
                                      currentImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                                    )
                                  : _imagePlaceholder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _imagePickerButtons(
                        onCamera: () async {
                          final image = await _pickImage(ImageSource.camera);
                          if (image != null) {
                            setDialogState(() => replacementImage = image);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('ยกเลิก', style: TextStyle(color: Colors.white60)),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _secondary),
                    onPressed: () {
                      final value = controller.text.trim();
                      if (value.isEmpty) return;
                      Navigator.of(dialogContext).pop({
                        'name': value,
                        'image': replacementImage,
                      });
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('บันทึก'),
                  ),
                ],
              );
            },
          );
        },
      );
      newName = result?['name'] as String?;
      replacementImage = result?['image'] as XFile?;
    } finally {
      await WidgetsBinding.instance.endOfFrame;
      controller.dispose();
    }

    if (newName == null || !mounted) return;
    String? uploadedUrl;
    try {
      if (replacementImage != null) {
        uploadedUrl = await _uploadImage(replacementImage!);
      }
      await _db.updateItem(
        documentId: documentId,
        name: newName,
        imageUrl: uploadedUrl,
      );
      if (uploadedUrl != null && currentImageUrl != null && currentImageUrl != uploadedUrl) {
        await _deleteStorageImage(currentImageUrl);
      }
      if (!mounted) return;
      _showMessage('แก้ไขรายการสำเร็จ');
    } catch (e) {
      await _deleteStorageImage(uploadedUrl);
      if (!mounted) return;
      _showMessage('แก้ไขรายการไม่สำเร็จ: $e', isError: true);
    }
  }

  Future<void> _deleteItem({
    required String documentId,
    required String name,
    required String? imageUrl,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 42),
          title: const Text('ยืนยันการลบ', style: TextStyle(color: Colors.white)),
          content: Text(
            'ต้องการลบรายการ "$name" ใช่หรือไม่?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.white60)),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete),
              label: const Text('ลบรายการ'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    try {
      await _db.deleteItem(documentId);
      await _deleteStorageImage(imageUrl);
      if (!mounted) return;
      _showMessage('ลบรายการสำเร็จ');
    } catch (e) {
      if (!mounted) return;
      _showMessage('ลบรายการไม่สำเร็จ: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? Colors.redAccent.shade700 : const Color(0xFF3730A3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;
      _showMessage('ออกจากระบบไม่สำเร็จ: $e', isError: true);
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      color: _background,
      alignment: Alignment.center,
      child: const Icon(Icons.music_note_rounded, color: _primary, size: 38),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.library_music, color: _primary),
            SizedBox(width: 10),
            Text('Firebase Library', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'ออกจากระบบ',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
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
                  boxShadow: [
                    BoxShadow(
                      color: _secondary.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_done_rounded, color: Colors.white, size: 30),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'เชื่อมต่อ Firebase สำเร็จ',
                            style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.email ?? 'ไม่พบอีเมลบัญชี',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'UID: ${user?.uid ?? "-"}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.add_circle, color: _primary),
                        SizedBox(width: 8),
                        Text(
                          'เพิ่มรายการใหม่',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nameController,
                      enabled: !_saving,
                      maxLength: 100,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'กรอกชื่อรายการ เช่น เพลงที่ชอบ',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.music_note, color: _primary),
                        filled: true,
                        fillColor: _background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!_saving) _addItem();
                      },
                    ),
                    const SizedBox(height: 12),
                    _imagePickerButtons(onCamera: () => _selectImage(ImageSource.camera)),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 12),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              File(_selectedImage!.path),
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton.filled(
                            tooltip: 'เอารูปออก',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => setState(() => _selectedImage = null),
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
                        onPressed: _saving ? null : _addItem,
                        style: FilledButton.styleFrom(
                          backgroundColor: _secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          _saving ? 'กำลังบันทึก...' : 'เพิ่มข้อมูล',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'รายการของฉัน',
                      style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Firestore',
                      style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => _searchText = value.trim().toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'ค้นหาจากชื่อรายการ...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: _primary),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          tooltip: 'ล้างการค้นหา',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchText = '');
                          },
                          icon: const Icon(Icons.close, color: Colors.white60),
                        )
                      : null,
                  filled: true,
                  fillColor: _surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _db.watchItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildStatus(
                      icon: Icons.cloud_off,
                      title: 'โหลดข้อมูลไม่สำเร็จ',
                      subtitle: '${snapshot.error}',
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: _primary));
                  }
                  final allDocs = snapshot.data?.docs ?? [];
                  final docs = allDocs.where((doc) {
                    final name = (doc.data()['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchText);
                  }).toList();

                  if (docs.isEmpty) {
                    return _buildStatus(
                      icon: _searchText.isNotEmpty ? Icons.search_off : Icons.library_music_outlined,
                      title: _searchText.isNotEmpty ? 'ไม่พบรายการที่ค้นหา' : 'ยังไม่มีรายการ',
                      subtitle: _searchText.isNotEmpty
                          ? 'ลองค้นหาด้วยชื่ออื่น'
                          : 'เพิ่มรายการแรกของคุณได้จากด้านบน',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final name = data['name']?.toString() ?? 'ไม่มีชื่อ';
                      final imageUrl = data['imageUrl']?.toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 54,
                              height: 54,
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                                    )
                                  : _imagePlaceholder(),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'ID: ${doc.id}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            tooltip: 'จัดการรายการ',
                            color: _surface,
                            icon: const Icon(Icons.more_vert, color: Colors.white70),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editItem(
                                  documentId: doc.id,
                                  currentName: name,
                                  currentImageUrl: imageUrl,
                                );
                              } else if (value == 'delete') {
                                _deleteItem(
                                  documentId: doc.id,
                                  name: name,
                                  imageUrl: imageUrl,
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, color: _primary),
                                    SizedBox(width: 10),
                                    Text('แก้ไข', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, color: Colors.redAccent),
                                    SizedBox(width: 10),
                                    Text('ลบรายการ', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: _primary, size: 38),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}