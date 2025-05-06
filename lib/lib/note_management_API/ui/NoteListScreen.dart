import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Note.dart'; // Lớp Note của bạn
import '../api/NoteAPIService.dart'; // Đã đổi tên class
import 'NoteForm.dart';
import 'NoteDetailScreen.dart';
import 'NoteItem.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  // Sử dụng instance của NoteAPIService thông qua singleton
  final NoteAPIService _apiService = NoteAPIService.instance;
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  bool _isGridView = false;
  int? _filterPriority;
  String _sortBy = 'modifiedAt'; // Sắp xếp mặc định theo thời gian sửa đổi mới nhất

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final notes = await _apiService.getAllNotes();
      setState(() {
        _notes = notes;
        _filterAndSortNotes();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải ghi chú: $e')),
      );
    }
  }

  void _filterAndSortNotes() {
    setState(() {
      _filteredNotes = _notes.where((note) {
        final titleLower = note.title.toLowerCase();
        final contentLower = note.content.toLowerCase();
        final queryLower = _searchQuery.toLowerCase();
        final priorityMatch = _filterPriority == null || note.priority == _filterPriority;
        final searchMatch = titleLower.contains(queryLower) || contentLower.contains(queryLower);
        return priorityMatch && searchMatch;
      }).toList();

      if (_sortBy == 'priority') {
        _filteredNotes.sort((a, b) => b.priority.compareTo(a.priority));
      } else if (_sortBy == 'createdAt') {
        _filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (_sortBy == 'modifiedAt') {
        _filteredNotes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _filterAndSortNotes();
    });
  }

  Future<void> _deleteNote(int id) async {
    try {
      await _apiService.deleteNote(id);
      // Nếu không có exception nào bị ném ra, nghĩa là xóa thành công (status code 200)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa ghi chú thành công.')),
      );
      _fetchNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')),
      );
    }
  }

  Future<void> _navigateToNoteDetail(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note, onNoteUpdated: _fetchNotes)),
    );
    // Không cần kiểm tra 'result is bool && result' ở đây nữa,
    // vì NoteDetailScreen giờ không trả về boolean trực tiếp.
  }

  Future<void> _navigateToNoteForm({Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteForm(existingNote: note)),
    );
    if (result != null && result is Note) {
      // Khi thêm mới hoặc sửa thành công, gọi API tương ứng
      try {
        Note? savedNote;
        if (note == null) {
          savedNote = await _apiService.insertNote(result);
          if (savedNote != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã thêm ghi chú thành công.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi thêm ghi chú.')),
            );
          }
        } else {
          savedNote = await _apiService.updateNote(result);
          if (savedNote != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã cập nhật ghi chú thành công.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi cập nhật ghi chú.')),
            );
          }
        }
        if (savedNote != null) {
          _fetchNotes(); // Tải lại danh sách sau khi thêm hoặc sửa
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối hoặc server: $e')),
        );
      }
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green.shade200;
      case 2:
        return Colors.yellow.shade200;
      case 3:
        return Colors.red.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                _deleteNote(id);
                Navigator.of(context).pop();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi chú của bạn'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchNotes,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _filterAndSortNotes();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'priority',
                child: Text('Ưu tiên'),
              ),
              const PopupMenuItem<String>(
                value: 'createdAt',
                child: Text('Thời gian tạo'),
              ),
              const PopupMenuItem<String>(
                value: 'modifiedAt',
                child: Text('Thời gian sửa đổi'),
              ),
            ],
            icon: Icon(Icons.sort),
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _filterPriority = value;
                _filterAndSortNotes();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: null,
                child: Text('Tất cả ưu tiên'),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Ưu tiên thấp'),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('Ưu tiên trung bình'),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: Text('Ưu tiên cao'),
              ),
            ],
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _filteredNotes.isEmpty
          ? Center(child: Text('Không có ghi chú nào.'))
          : _isGridView
          ? GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) {
          final note = _filteredNotes[index];
          return NoteItem(
            note: note,
            onNoteUpdated: _fetchNotes,
            onTap: () => _navigateToNoteDetail(note),
          );
        },
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) {
          final note = _filteredNotes[index];
          return NoteItem(
            note: note,
            onNoteUpdated: _fetchNotes,
            onTap: () => _navigateToNoteDetail(note),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNoteForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}