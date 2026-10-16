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
  final _formKey = GlobalKey<FormState>();
  final _songController = TextEditingController();
  final _artistController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _moods = ['Pop', 'Rock', 'Metal', 'Indie', 'R&B Soul', 'EDM', 'Jazz', 'Acoustic / Folk'];
  String _selectedType = 'Pop';
  DateTime _selectedDate = DateTime.now();
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
      _contentController.text = '${widget.quote?.text ?? ''} ${widget.climate?.current.temperature2m ?? ''} ${widget.climate?.currentUnits.temperature2m ?? ''}';
    }
  }

  @override
  void dispose() {
    _songController.dispose();
    _artistController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF9C6BFF);
    return Scaffold(
      backgroundColor: const Color(0xFF08070D),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(widget.existing == null ? 'เขียนบันทึกใหม่' : 'แก้ไขบันทึก', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF24113D), Color(0xFF120D20), Color(0xFF08070D), Colors.black],
            stops: [0, 0.3, 0.7, 1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white.withOpacity(0.06), border: Border.all(color: Colors.white.withOpacity(0.08))),
                  child: Row(children: [
                    const Icon(Icons.music_note, color: Color(0xFFB084FF), size: 25),
                    const SizedBox(width: 10),
                    Text(widget.existing == null ? 'บันทึกเพลงของ' : 'แก้ไขบันทึกเพลง', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 16),
                _buildField(_songController, 'ชื่อเพลง', 'กรุณากรอกชื่อเพลง'),
                const SizedBox(height: 12),
                _buildField(_artistController, 'เจ้าของเพลง', 'กรุณากรอกเจ้าของเพลง'),
                const SizedBox(height: 12),
                _buildField(_contentController, 'เนื้อหา', 'กรุณากรอกเนื้อหา', maxLines: 4),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  dropdownColor: const Color(0xFF1B1725),
                  style: const TextStyle(color: Colors.white),
                  decoration: _decoration('แนวเพลงวันนี้'),
                  items: _moods.map((mood) => DropdownMenuItem(value: mood, child: Text(mood))).toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white.withOpacity(0.06),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    leading: const Icon(Icons.calendar_today, color: Color(0xFFB084FF)),
                    title: Text('วันที่: ${_selectedDate.toString().substring(0, 10)}', style: const TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.edit, color: Color(0xFFB084FF)),
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ทำเครื่องหมายว่าสำคัญ', style: TextStyle(color: Colors.white)),
                  value: _isImportant,
                  activeColor: primary,
                  onChanged: (value) => setState(() => _isImportant = value!),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ปักหมุดบันทึก', style: TextStyle(color: Colors.white)),
                  value: _isPinned,
                  activeColor: const Color(0xFFEC4899),
                  onChanged: (value) => setState(() => _isPinned = value),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ส่วนตัว', style: TextStyle(color: Colors.white)),
                  value: 'ส่วนตัว',
                  groupValue: _type,
                  activeColor: primary,
                  onChanged: (value) => setState(() => _type = value!),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('งาน', style: TextStyle(color: Colors.white)),
                  value: 'งาน',
                  groupValue: _type,
                  activeColor: const Color(0xFFEC4899),
                  onChanged: (value) => setState(() => _type = value!),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)])),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        Navigator.pop(context, Song(
                          id: widget.existing?.id,
                          song: _songController.text.trim(),
                          artist: _artistController.text.trim(),
                          content: _contentController.text.trim(),
                          date: _selectedDate.toString().substring(0, 10),
                          type: _selectedType,
                        ));
                      },
                      child: const Text('บันทึก', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
    filled: true,
    fillColor: Colors.white.withOpacity(0.06),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF9C6BFF))),
  );

  Widget _buildField(TextEditingController controller, String label, String error, {int maxLines = 1}) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    style: const TextStyle(color: Colors.white),
    decoration: _decoration(label).copyWith(alignLabelWithHint: maxLines > 1),
    validator: (value) => value == null || value.trim().isEmpty ? error : null,
  );
}