import 'package:flutter/material.dart';
import '../Model/Note.dart';
import 'NoteForm.dart';
import '../Database Helper/NoteDatabaseHelper.dart';
import 'NoteDetailScreen.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete; // Callback khi xóa thành công
  final VoidCallback onUpdate; // Callback khi ghi chú được cập nhật

  const NoteItem({
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  int _hexToInt(String hex) {
    hex = hex.replaceAll('#', '');
    return int.parse('FF$hex', radix: 16);
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(
        2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(
        2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = note.color != null
        ? Color(_hexToInt(note.color!))
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
                  );
                  if (result == true) onUpdate();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag, color: _getPriorityColor(note.priority), size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              decoration: note.isDone == 1 ? TextDecoration.lineThrough : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (note.imagePath != null && note.imagePath!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(note.imagePath!),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      note.content,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          decoration: note.isDone == 1 ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (note.tags != null && note.tags!.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: (note.tags ?? []).map((tag) => Chip(
                          label: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: Text(
                              tag,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          backgroundColor: Colors.grey[100],
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.zero,
                        )).toList(),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Cập nhật: ${_formatDate(note.modifiedAt)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(
                        note.isDone == 1 ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: note.isDone == 1 ? Colors.green : Colors.grey,
                      ),
                      tooltip: note.isDone == 1 ? 'Đã hoàn thành' : 'Chưa hoàn thành',
                      onPressed: () async {
                        final updatedNote = note.copyWith(isDone: note.isDone == 1 ? 0 : 1);
                        await NoteDatabaseHelper().updateNote(updatedNote);
                        onUpdate();
                      },
                    ),
                  ),
                  Flexible(
                    child: IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NoteForm(note: note)),
                        );
                        if (updated == true) onUpdate();
                      },
                    ),
                  ),
                  Flexible(
                    child: IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: const Icon(Icons.share, color: Colors.teal),
                      tooltip: 'Chia sẻ ghi chú',
                      onPressed: () {
                        final shareText = '''
              📌 ${note.title}
              ${note.content}
              
              🕒 Cập nhật: ${_formatDate(note.modifiedAt)}
              📋 Ưu tiên: ${note.priority}
                        ''';
                        Share.share(shareText);
                      },
                    ),
                  ),
                  Flexible(
                    child: IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xoá ghi chú?'),
                            content: const Text('Bạn có chắc muốn xoá ghi chú này?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Huỷ'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Xoá'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await NoteDatabaseHelper().deleteNote(note.id!);
                          onDelete();
                        }
                      },
                    ),
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