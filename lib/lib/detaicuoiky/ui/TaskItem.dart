import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../db/database.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final Function(Task) onEdit;
  final Function(Task) onDelete;
  final Function(Task) onToggleComplete;

  const TaskItem({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  final DBHelper _dbHelper = DBHelper();
  String? _assignedToName;

  @override
  void initState() {
    super.initState();
    _loadAssignedUser();
  }

  Future<void> _loadAssignedUser() async {
    if (widget.task.assignedTo != null) {
      final name = await _dbHelper.getUsernameById(widget.task.assignedTo!);
      setState(() {
        _assignedToName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Dismissible(
      key: Key(task.id.toString()),
      background: _buildSwipeActionLeft(),
      secondaryBackground: _buildSwipeActionRight(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Vuốt sang phải: xác nhận xoá
          return await _confirmDelete(context);
        } else {
          // Vuốt sang trái: gọi sửa
          widget.onEdit(task);
          return false; // không xoá
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getPriorityColor(task.priority),
            child: Text(
              _getPriorityLabel(task.priority).substring(0, 1),
              style: TextStyle(color: Colors.white),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag, size: 16, color: _getPriorityColor(task.priority)),
                  SizedBox(width: 4),
                  Text('Ưu tiên: ${_getPriorityLabel(task.priority)}'),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.timelapse, size: 16),
                  SizedBox(width: 4),
                  Text('Trạng thái: ${task.status}'),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16),
                  SizedBox(width: 4),
                  Text('Hạn chót: ${task.dueDate != null ? DateFormat('dd/MM/yyyy').format(task.dueDate!) : 'Chưa có'}'),
                ],
              ),
              if (task.category != null && task.category!.isNotEmpty)
                Text('Danh mục: ${task.category}'),
              if (task.assignedTo != null)
                Row(
                  children: [
                    Icon(Icons.person, size: 16),
                    SizedBox(width: 4),
                    Text('Giao cho: ${_assignedToName ?? "Đang tải..."}'),
                  ],
                ),
              if (task.attachments != null && task.attachments!.isNotEmpty)
                Text('Tệp đính kèm: ${task.attachments!.length} tệp'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeActionLeft() {
    return Container(
      color: Colors.green,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20),
      child: Icon(Icons.edit, color: Colors.white),
    );
  }

  Widget _buildSwipeActionRight() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      child: Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xoá'),
        content: Text('Bạn có chắc chắn muốn xoá công việc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(widget.task);
              Navigator.of(ctx).pop(true);
            },
            child: Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
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

  String _getPriorityLabel(int priority) {
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
}
