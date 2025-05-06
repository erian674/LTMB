import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../db/database.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}
class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final DBHelper _dbHelper = DBHelper();
  late Task _task;

  String? _assignedToName;
  String? _createdByName;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _loadUsernames();
  }
  Future<void> _loadUsernames() async {
    final assignedTo = _task.assignedTo;
    final createdBy = _task.createdBy;

    final assignedName = assignedTo != null ? await _dbHelper.getUsernameById(assignedTo) : null;
    final createdName = createdBy != null ? await _dbHelper.getUsernameById(createdBy) : null;

    setState(() {
      _assignedToName = assignedName;
      _createdByName = createdName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        backgroundColor: Colors.teal,  // Màu sắc tươi sáng cho app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              task.title,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 12),
            Text(
              'Mô tả: ${task.description ?? 'Không có mô tả'}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 12),
            _buildStatusRow(task),
            SizedBox(height: 12),
            Text(
              'Độ ưu tiên: ${_getPriorityString(task.priority)}',
              style: TextStyle(fontSize: 16, color: Colors.teal),
            ),
            SizedBox(height: 12),
            Text(
              'Hạn chót: ${task.dueDate != null ? DateFormat('dd/MM/yyyy').format(task.dueDate!) : 'Chưa có hạn chót'}',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 12),
            Text('Giao cho: ${_assignedToName ?? 'Đang tải...'}',
                style: TextStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 12),
            Text('Tạo bởi: ${_createdByName ?? 'Đang tải...'}',
                style: TextStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 12),
            if (task.category != null && task.category!.isNotEmpty)
              Text(
                'Danh mục: ${task.category}',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            SizedBox(height: 16),
            _buildAttachmentsSection(task),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Cập nhật trạng thái',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStatusRow(Task task) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          color: Colors.teal,
        ),
        SizedBox(width: 8),
        Text(
          'Trạng thái: ${task.status}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(Task task) {
    return task.attachments != null && task.attachments!.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tệp đính kèm:', style: TextStyle(fontSize: 16, color: Colors.teal)),
        ...task.attachments!.map((attachment) {
          return ListTile(
            leading: Icon(Icons.attach_file, color: Colors.teal),
            title: Text(attachment),
            subtitle: Text('Nhấp để xem', style: TextStyle(color: Colors.teal)),
            onTap: () {
              // Xử lý mở tệp khi người dùng nhấn vào
            },
          );
        }).toList(),
      ],
    )
        : Text('Không có tệp đính kèm', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54));
  }

  String _getPriorityString(int priority) {
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

  Future<void> _updateStatus() async {
    String newStatus = _getNextStatus(_task.status);
    Task updatedTask = _task.copyWith(status: newStatus);
    await _dbHelper.updateTask(updatedTask);
    setState(() {
      _task = updatedTask;
    });
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Chưa hoàn thành':
        return 'Đang xử lý';
      case 'Đang xử lý':
        return 'Đã hoàn thành';
      case 'Đã hoàn thành':
        return 'Chưa hoàn thành';
      default:
        return 'Chưa hoàn thành';
    }
  }
}