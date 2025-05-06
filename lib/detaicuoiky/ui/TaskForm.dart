import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../models/task.dart';
import '../models/user.dart';

class TaskFormScreen extends StatefulWidget {
  final User currentUser;
  final Task? task;

  const TaskFormScreen({required this.currentUser, this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _createdByController = TextEditingController();
  final _attachmentsController = TextEditingController();
  String _status = 'Chưa hoàn thành';
  int _priority = 2;
  DateTime? _dueDate;
  String? _assignedUserId;
  List<User> _users = [];
  final _dbHelper = DBHelper();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description ?? '';
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _categoryController.text = widget.task!.category ?? '';
      _assignedUserId = widget.task!.assignedTo;
      _createdByController.text = widget.task!.createdBy;
      _attachmentsController.text = widget.task!.attachments?.join(', ') ?? '';
    }
  }

  Future<void> _loadUsers() async {
    final users = await _dbHelper.getAllUsers();

    // Nếu là admin, được phép gán cho chính mình
    if (widget.currentUser.isAdmin) {
      setState(() => _users = users);
    } else {
      // Người dùng thường chỉ gán cho chính họ (hoặc không được gán)
      setState(() => _users = users.where((u) => !u.isAdmin).toList());
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final task = Task(
      id: widget.task?.id ?? Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      dueDate: _dueDate,
      status: _status,
      assignedTo: widget.currentUser.isAdmin
          ? _assignedUserId
          : widget.currentUser.id,
      priority: _priority,  // Thêm priority
      createdBy: widget.currentUser.id, // Gán createdBy từ người dùng hiện tại
      category: _categoryController.text.trim(),
      attachments: _attachmentsController.text.isNotEmpty
          ? _attachmentsController.text.split(', ').toList()
          : [],
    );

    if (widget.task == null) {
      await _dbHelper.insertTask(task);
    } else {
      await _dbHelper.updateTask(task);
    }

    setState(() => _loading = false);
    Navigator.pop(context, true);
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _pickAttachments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        // Lưu các tệp đã chọn vào attachments
        _attachmentsController.text = result.files.map((e) => e.name).join(', ');
      });
    }
  }

  void _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Xóa công việc?"),
        content: Text("Bạn chắc chắn muốn xóa công việc này?"),
        actions: <Widget>[
          TextButton(
            child: Text('Hủy'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Xóa'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteTask(widget.task!.id);  // Xóa task
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa công việc' : 'Tạo công việc'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) =>
                val!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  _dueDate != null
                      ? 'Hạn chót: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}'
                      : 'Chưa chọn hạn chót',
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.blue),
                onTap: _pickDate,
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                items: ['Chưa hoàn thành', 'Đang xử lý', 'Đã hoàn thành']
                    .map((status) => DropdownMenuItem(
                  child: Text(status),
                  value: status,
                ))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: 'Mức độ ưu tiên',
                  border: OutlineInputBorder(),
                ),
                items: [1, 2, 3]
                    .map((level) => DropdownMenuItem(
                  value: level,
                  child: Text('Mức $level'),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              SizedBox(height: 16),
              if (widget.currentUser.isAdmin)
                DropdownButtonFormField<String>(
                  value: _assignedUserId,
                  decoration: InputDecoration(
                    labelText: 'Giao cho người dùng',
                    border: OutlineInputBorder(),
                  ),
                  items: _users.map((user) => DropdownMenuItem(
                    child: Text(user.username),
                    value: user.id,
                  )).toList(),
                  onChanged: (val) => setState(() => _assignedUserId = val),
                  validator: (val) => val == null ? 'Vui lòng chọn người dùng' : null,
                ),
              SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _attachmentsController,
                decoration: InputDecoration(
                  labelText: 'Tệp đính kèm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_file),
                ),
                readOnly: true,
                onTap: _pickAttachments,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEditing ? 'Cập nhật' : 'Tạo mới'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}