import 'package:flutter/material.dart';

import 'package:my_playlist/models/song.dart';
import 'package:my_playlist/models/quote.dart';
import 'package:my_playlist/models/climate.dart';

class AddSongPage extends StatefulWidget {
  final Song? existing;
  final Quote? quote;
  final Climate? climate;
  const AddSongPage({super.key, this.existing, this.quote, this.climate});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _formKey = GlobalKey<FormState>(); // กุญแจคุมฟอร์ม
  final _songController = TextEditingController(); // อ่านค่าช่องชื่อเพลง
  final _artistController = TextEditingController(); // อ่านค่าช่องเจ้าของเพลง
  final _contentController = TextEditingController(); // อ่านค่าช่องเนื้อหา
  String _selectedType = 'Pop'; // ค่าเริ่มต้น
  final List<String> _moods = [
    'Pop',
    'Rock',
    'Metal',
    'Indie',
    'R&B Soul',
    'EDM',
    'Jazz',
    'Acoustic / Folk',
  ];

  DateTime _selectedDate = DateTime.now(); // เริ่มที่วันนี้
  bool _isImportant = false;
  bool _isPinned = false;
  String _type = 'ส่วนตัว';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _songController.text = widget.existing!.song;
      _artistController.text = widget.existing!.artist;
      _contentController.text = widget.existing!.content;
      _selectedType = widget.existing!.type;
      _selectedDate = DateTime.parse(widget.existing!.date);
    }
    if (widget.quote != null || widget.climate != null) {
      _contentController.text ='${widget.quote?.text ?? ''} ${widget.climate?.current.temperature2m ?? ''} ${widget.climate?.currentUnits.temperature2m ?? ''}';
    }
  }

  @override
  void dispose() {
    _songController.dispose(); // คืนทรัพยากรตอนปิดหน้า
    _artistController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08070D),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          widget.existing == null ? 'เขียนบันทึกใหม่' : 'แก้ไขบันทึก',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF24113D),
              Color(0xFF120D20),
              Color(0xFF08070D),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.music_note,
                          color: Color(0xFFB084FF),
                          size: 25,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.existing == null
                              ? 'บันทึกเพลงของ'
                              : 'แก้ไขบันทึกเพลง',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _songController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'ชื่อเพลง',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9C6BFF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกชื่อเพลง';
                      }
                      return null; // null = ผ่าน
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _artistController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'เจ้าของเพลง',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9C6BFF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกเจ้าของเพลง';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 4, // ช่องเนื้อหาสูง 4 บรรทัด
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'เนื้อหา',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9C6BFF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกเนื้อหา';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: const Color(0xFF1B1725),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'แนวเพลงวันนี้',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9C6BFF)),
                      ),
                    ),
                    items: _moods.map((mood) {
                      return DropdownMenuItem(value: mood, child: Text(mood));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        // เลือกค่าเลือกต้อง setState เอง
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ), // เว้นระยะห่างเล็กน้อยก่อนเข้าปุ่มวันที่
                  Card(
                    // ครอบด้วย Card เพื่อความสวยงามเป็นสัดส่วน
                    color: Colors.white.withOpacity(0.06),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFB084FF),
                      ),
                      title: Text(
                        'วันที่: ${_selectedDate.toString().substring(0, 10)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(
                        Icons.edit,
                        color: Color(0xFFB084FF),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          // เปิดปฏิทินให้เลือก
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020), // เลือกได้ตั้งแต่ปี 2020
                          lastDate: DateTime(2030), // ถึงปี 2030
                        );
                        if (picked != null) {
                          // ถ้าเลือก (ไม่กดยกเลิก)
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'ทำเครื่องหมายว่าสำคัญ',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _isImportant,
                    activeColor: const Color(0xFF9C6BFF),
                    onChanged: (value) => setState(() => _isImportant = value!),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'ปักหมุดบันทึก',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _isPinned,
                    activeColor: const Color(0xFFEC4899),
                    onChanged: (value) => setState(() => _isPinned = value),
                  ),
                  Column(
                    children: [
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'ส่วนตัว',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'ส่วนตัว',
                        groupValue: _type,
                        activeColor: const Color(0xFF9C6BFF),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'งาน',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'งาน',
                        groupValue: _type,
                        activeColor: const Color(0xFFEC4899),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // validate เช็คแค่ TextFormField
                            final newDiary = Song(
                              id: widget.existing?.id,
                              song: _songController.text.trim(),
                              artist: _artistController.text.trim(),
                              content: _contentController.text.trim(),
                              date: _selectedDate.toString().substring(
                                0,
                                10,
                              ), // วันที่ที่เลือก
                              type: _selectedType, // แนวเพลงที่เลือก
                            );
                            Navigator.pop(context, newDiary);
                          }
                        },
                        child: const Text(
                          'บันทึก',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}