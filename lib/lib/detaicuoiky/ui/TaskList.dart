import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database.dart';
import 'Taskform.dart';
import 'Taskdetail.dart';
import '../models/user.dart';
import '../models/task.dart';
import 'Login.dart';
import 'ChangePasswordScreen.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;

  const HomeScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Task> _tasks = [];
  String _searchQuery = '';
  Map<int, String> _usernamesById = {};
  bool _isKanbanView = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    List<Task> tasks;
    if (widget.currentUser.isAdmin) {
      tasks = await _dbHelper.getAllTasks();
    } else {
      tasks = await _dbHelper.getTasksForUser(widget.currentUser.id!, widget.currentUser.isAdmin ? 'admin' : 'user');
    }

    // Nếu là admin, tải tên người dùng của tất cả assignedTo
    Map<int, String> usernames = {};
    if (widget.currentUser.isAdmin) {
      Set<String> assignedUserIds = tasks
          .where((task) => task.assignedTo != null)
          .map((task) => task.assignedTo!)
          .toSet();

      for (String id in assignedUserIds) {
        final name = await _dbHelper.getUsernameById(id);
        if (name != null) {
          usernames[int.tryParse(id) ?? -1] = name;
        }
      }
    }

    setState(() {
      _tasks = tasks;
      _usernamesById = usernames;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'Không có';
    return DateFormat('dd/MM/yyyy').format(dueDate);
  }
  String _priorityLabel(int p) {
    switch (p) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không rõ';
    }
  }

  Future<void> _deleteTask(Task task) async {
    await _dbHelper.deleteTask(task.id!);
    _loadTasks();
  }

  Future<void> _editTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(currentUser: widget.currentUser, task: task),
      ),
    );
    _loadTasks();
  }

  Future<bool> _confirmDelete(Task task) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xoá'),
        content: Text('Bạn có chắc chắn muốn xoá công việc này?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Huỷ')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Xoá')),
        ],
      ),
    ) ??
        false;
  }

  Color _priorityColor(int p) {
    switch (p) {
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

  Widget _buildTaskCard(Task task) {
    return Dismissible(
      key: Key(task.id.toString()),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _editTask(task);
          return false;
        } else {
          return await _confirmDelete(task).then((confirmed) {
            if (confirmed) _deleteTask(task);
            return confirmed;
          });
        }
      },
      child: Card(
        elevation: 5, // Thêm độ nổi cho thẻ
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bo góc cho thẻ
        ),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Phần biểu tượng ưu tiên
              CircleAvatar(
                backgroundColor: _priorityColor(task.priority),
                child: Text(
                  task.priority.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 15),
              // Phần tiêu đề và thông tin công việc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Trạng thái: ${task.status}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Hạn chót: ${_formatDueDate(task.dueDate)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    if (task.attachments != null && task.attachments!.isNotEmpty)
                      Text(
                        'Tệp đính kèm: ${task.attachments!.length} tệp',
                        style: TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
              // Thêm các biểu tượng nếu có
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) return Center(child: Text('Không có công việc nào'));
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(task: task),
              ),
            );
          },
          child: _buildTaskCard(task), // bạn đã có sẵn đoạn hiển thị task bằng Card/ListTile
        );
      },
    );
  }


  Widget _buildKanbanBoard(List<Task> tasks) {
    final statuses = ['Chưa hoàn thành', 'Đang xử lý', 'Đã hoàn thành'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final statusTasks = tasks.where((t) => t.status == status).toList();
          return Container(
            width: 300,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    status,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                ...statusTasks.map((task) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(task: task),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text('Hạn: ${_formatDueDate(task.dueDate)}'),
                    ),
                  ),
                )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = _tasks.where((task) {
      final matchesQuery = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == null || _selectedStatus == 'Tất cả' || task.status == _selectedStatus;
      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.currentUser.avatar != null
                  ? FileImage(File(widget.currentUser.avatar!))
                  : null,
              child: widget.currentUser.avatar == null
                  ? Text(widget.currentUser.username[0].toUpperCase())
                  : null,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.currentUser.username,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.lock),
            tooltip: 'Đổi mật khẩu',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
              );
            },
          ),
          // Lọc trạng thái bằng icon
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() {
                _selectedStatus = status;
              });
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Tất cả',
                child: Text('Tất cả'),
              ),
              const PopupMenuItem<String>(
                value: 'Chưa hoàn thành',
                child: Text('Chưa hoàn thành'),
              ),
              const PopupMenuItem<String>(
                value: 'Đang xử lý',
                child: Text('Đang xử lý'),
              ),
              const PopupMenuItem<String>(
                value: 'Đã hoàn thành',
                child: Text('Đã hoàn thành'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(_isKanbanView ? Icons.view_list : Icons.view_kanban),
            onPressed: () {
              setState(() {
                _isKanbanView = !_isKanbanView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công việc',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isKanbanView
                ? _buildKanbanBoard(filteredTasks)
                : _buildTaskList(filteredTasks),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(currentUser: widget.currentUser),
            ),
          );
          _loadTasks();
        },
      ),
    );
  }
}