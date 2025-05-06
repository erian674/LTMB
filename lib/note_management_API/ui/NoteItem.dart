import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/NoteAPIService.dart'; // Import lớp APIService
import '../model/Note.dart';
import 'NoteForm.dart'; // Lớp Note của bạn

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onNoteUpdated;
  final VoidCallback? onTap;

  // Sử dụng instance của NoteAPIService thông qua singleton
  final NoteAPIService _apiService = NoteAPIService.instance;

  NoteItem({required this.note, required this.onNoteUpdated, this.onTap});

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green.shade100;
      case 2:
        return Colors.yellow.shade100;
      case 3:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Future<void> _deleteNote(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
              ],
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
              onPressed: () async {
                try {
                  await _apiService.deleteNote(note.id!);
                  onNoteUpdated(); // Gọi callback để cập nhật danh sách
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa ghi chú.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getPriorityColor(note.priority).withOpacity(0.8),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap, // Sử dụng onTap nếu được cung cấp
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.0),
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.0),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    '${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey.shade700),
                  ),
                  Spacer(),
                  if (note.tags != null && note.tags!.isNotEmpty)
                    Wrap(
                      spacing: 4.0,
                      children: note.tags!
                          .map((tag) => Chip(
                        label: Text(
                          tag,
                          style: TextStyle(fontSize: 10.0),
                        ),
                      ))
                          .toList(),
                    ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                        onNoteUpdated();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNote(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}