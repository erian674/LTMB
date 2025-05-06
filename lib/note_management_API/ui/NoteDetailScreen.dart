import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Note.dart'; // Lớp Note của bạn
import 'NoteForm.dart'; // Lớp NoteDatabaseHelper của bạn

class NoteDetailScreen extends StatelessWidget {
  final Note note;
  final VoidCallback? onNoteUpdated; // Callback để thông báo cập nhật

  NoteDetailScreen({required this.note, this.onNoteUpdated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ghi chú'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteForm(existingNote: note),
                ),
              );
              if (result != null && result is Note) {
                // Sau khi chỉnh sửa thành công, gọi callback nếu có
                onNoteUpdated?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ghi chú đã được cập nhật.')),
                );
                // Không cần pop ở đây nếu màn hình danh sách tự cập nhật
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            _buildDetailRow(Icons.priority_high, _getPriorityColor(note.priority), _getPriorityText(note.priority)),
            SizedBox(height: 8.0),
            _buildDetailRow(Icons.calendar_today, Colors.grey, 'Đã tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(note.createdAt)}'),
            SizedBox(height: 8.0),
            _buildDetailRow(Icons.edit_calendar, Colors.grey, 'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}'),
            SizedBox(height: 16.0),
            Text(
              'Nội dung:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              note.content,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            if (note.tags != null && note.tags!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhãn:',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    children: note.tags!
                        .map((tag) => Chip(label: Text(tag)))
                        .toList(),
                  ),
                ],
              ),
            if (note.color != null && note.color!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Màu sắc: ',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: _getColorFromString(note.color!),
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(note.color!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        SizedBox(width: 8.0),
        Expanded(child: Text(text, style: TextStyle(fontSize: 16.0))),
      ],
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }

  Color? _getColorFromString(String colorString) {
    if (colorString.startsWith('#') && colorString.length == 7) {
      final hexColor = colorString.substring(1);
      final color = int.parse(hexColor, radix: 16) + 0xFF000000;
      return Color(color);
    }
    // You can add more logic to handle named colors if needed
    return null;
  }
}