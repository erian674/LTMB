import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import '../model/Note.dart'; // Lớp Note của bạn

class NoteForm extends StatefulWidget {
  final Note? existingNote;

  NoteForm({this.existingNote});

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  int _priority = 1;
  Color _selectedColor = Colors.white;
  List<String> _tags = [];
  TextEditingController _tagController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _priority = widget.existingNote!.priority;
      if (widget.existingNote!.color != null && widget.existingNote!.color!.isNotEmpty) {
        _selectedColor = _getColorFromString(widget.existingNote!.color!) ?? Colors.white;
      }
      _tags = widget.existingNote!.tags ?? [];
      if (widget.existingNote!.imagePath != null && widget.existingNote!.imagePath!.isNotEmpty) {
        _imageFile = File(widget.existingNote!.imagePath!);
      }
    }
  }

  Color? _getColorFromString(String colorString) {
    if (colorString.startsWith('#') && colorString.length == 7) {
      final hexColor = colorString.substring(1);
      final color = int.parse(hexColor, radix: 16) + 0xFF000000;
      return Color(color);
    }
    return null;
  }

  String _getStringFromColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('Không có ảnh nào được chọn.');
      }
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color currentColor = _selectedColor;
        return AlertDialog(
          title: const Text('Chọn màu sắc'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => currentColor = color,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Chọn'),
              onPressed: () {
                setState(() => _selectedColor = currentColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote == null ? 'Thêm ghi chú' : 'Chỉnh sửa ghi chú'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Tiêu đề', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Nội dung', border: OutlineInputBorder()),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text('Mức độ ưu tiên:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    Text('Thấp'),
                    SizedBox(width: 16.0),
                    Radio<int>(
                      value: 2,
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    Text('Trung bình'),
                    SizedBox(width: 16.0),
                    Radio<int>(
                      value: 3,
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    Text('Cao'),
                  ],
                ),
                SizedBox(height: 16.0),
                Text('Màu sắc:', style: TextStyle(fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                Text('Mã màu: ${_getStringFromColor(_selectedColor)}'),
                SizedBox(height: 16.0),
                Text('Nhãn:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: InputDecoration(labelText: 'Thêm nhãn', border: OutlineInputBorder()),
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                    IconButton(icon: Icon(Icons.add), onPressed: _addTag),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  children: _tags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(_tags.indexOf(tag)),
                  ))
                      .toList(),
                ),
                SizedBox(height: 16.0),
                Text('Hình ảnh:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _getImage(ImageSource.camera),
                        icon: Icon(Icons.camera_alt),
                        label: Text('Chụp ảnh'),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _getImage(ImageSource.gallery),
                        icon: Icon(Icons.photo_library),
                        label: Text('Chọn từ thư viện'),
                      ),
                    ),
                  ],
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      height: 100,
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final now = DateTime.now();
                        final newNote = Note(
                          id: widget.existingNote?.id,
                          title: _titleController.text,
                          content: _contentController.text,
                          priority: _priority,
                          createdAt: widget.existingNote?.createdAt ?? now,
                          modifiedAt: now,
                          tags: _tags.isNotEmpty ? _tags : null,
                          color: _getStringFromColor(_selectedColor),
                          imagePath: _imageFile?.path, // Lưu đường dẫn ảnh
                        );
                        Navigator.pop(context, newNote);
                      }
                    },
                    child: Text(widget.existingNote == null ? 'Lưu' : 'Cập nhật'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}