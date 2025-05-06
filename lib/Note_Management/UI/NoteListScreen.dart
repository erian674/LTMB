import 'package:flutter/material.dart';
import '../Model/Note.dart';
import 'NoteForm.dart';
import 'NoteItem.dart';
import '../Database Helper/NoteDatabaseHelper.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteDatabaseHelper _dbHelper = NoteDatabaseHelper();
  List<Note> _notes = [];
  String _searchQuery = '';
  bool _isGrid = false;
  int? _filterPriority;
  String _sortBy = 'time'; // 'priority' or 'time'

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    List<Note> notes = [];

    if (_searchQuery.trim().isNotEmpty) {
      notes = await _dbHelper.searchNotes(_searchQuery);
    } else if (_filterPriority != null) {
      notes = await _dbHelper.getNotesByPriority(_filterPriority!);
    } else {
      notes = await _dbHelper.getAllNotes();
    }

    notes.sort((a, b) {
      if (_sortBy == 'priority') {
        return b.priority.compareTo(a.priority);
      } else {
        return b.modifiedAt.compareTo(a.modifiedAt);
      }
    });

    setState(() {
      _notes = notes;
    });
  }

  void _showFilterDialog() async {
    int? selected = await showDialog<int>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("Lọc theo mức độ ưu tiên"),
        children: [
          SimpleDialogOption(
            child: Text("Tất cả"),
            onPressed: () => Navigator.pop(context, null),
          ),
          SimpleDialogOption(
            child: Text("Thấp"),
            onPressed: () => Navigator.pop(context, 1),
          ),
          SimpleDialogOption(
            child: Text("Trung bình"),
            onPressed: () => Navigator.pop(context, 2),
          ),
          SimpleDialogOption(
            child: Text("Cao"),
            onPressed: () => Navigator.pop(context, 3),
          ),
        ],
      ),
    );

    setState(() {
      _filterPriority = selected;
    });
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi chú của tôi'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: () {
              _searchController.clear();
              setState(() {
                _filterPriority = null;
                _searchQuery = '';
              });
              Future.microtask(() => _loadNotes());
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_alt),
            tooltip: 'Lọc theo ưu tiên',
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: 'Đổi chế độ hiển thị',
            onPressed: () {
              setState(() => _isGrid = !_isGrid);
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            tooltip: 'Sắp xếp',
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadNotes();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'time', child: Text('Theo thời gian')),
              PopupMenuItem(value: 'priority', child: Text('Theo ưu tiên')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
                _loadNotes();
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    Future.microtask(() => _loadNotes());
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _notes.isEmpty
          ? Center(child: Text('Không có ghi chú nào'))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isGrid
            ? GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240, // Gợi ý: 180–220 là ổn
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.45, // Chiều cao lớn hơn chiều ngang (hợp với ghi chú)
          ),
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            return NoteItem(
              note: _notes[index],
              onDelete: _loadNotes,
              onUpdate: _loadNotes,
            );
          },
        )
            : ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            return NoteItem(
              note: _notes[index],
              onDelete: _loadNotes,
              onUpdate: _loadNotes,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteForm()),
          );
          if (added == true) _loadNotes();
        },
        child: Icon(Icons.add),
        tooltip: 'Thêm ghi chú mới',
      ),
    );
  }
}
