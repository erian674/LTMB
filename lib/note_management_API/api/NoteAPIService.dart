import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Note.dart';

class NoteAPIService {
  static final NoteAPIService instance = NoteAPIService._init();
  final String baseUrl = 'https://my-json-server.typicode.com/kgduy/note';
  static const String _notesEndpoint = '/notes';

  NoteAPIService._init();

  // Create - Thêm note mới
  Future<Note> insertNote(Note note) async {
    final response = await http.post(
      Uri.parse('$baseUrl$_notesEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode == 201) {
      return Note.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create note: ${response.statusCode}');
    }
  }

  // Read - Đọc tất cả notes
  Future<List<Note>> getAllNotes() async {
    final response = await http.get(Uri.parse('$baseUrl$_notesEndpoint'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Note.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notes: ${response.statusCode}');
    }
  }

  // Read - Đọc note theo id
  Future<Note?> getNoteById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl$_notesEndpoint/$id'));

    if (response.statusCode == 200) {
      return Note.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to get note: ${response.statusCode}');
    }
  }

  // Update - Cập nhật note
  Future<Note> updateNote(Note note) async {
    if (note.id == null) {
      throw ArgumentError('Note ID cannot be null for update.');
    }
    final response = await http.put(
      Uri.parse('$baseUrl$_notesEndpoint/${note.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode == 200) {
      return Note.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update note: ${response.statusCode}');
    }
  }

  // Delete - Xoá note
  Future<bool> deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl$_notesEndpoint/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete note: ${response.statusCode}');
    }
  }

  // Đếm số lượng notes
  Future<int> countNotes() async {
    final notes = await getAllNotes();
    return notes.length;
  }

  // Xử lý lỗi chung (có thể không cần thiết vì đã throw Exception)
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('API error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  // Lọc notes theo priority
  Future<List<Note>> getNotesByPriority(int priority) async {
    final response = await http.get(Uri.parse('$baseUrl$_notesEndpoint?priority=$priority'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Note.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notes by priority: ${response.statusCode}');
    }
  }

  // Tìm kiếm notes theo tiêu đề hoặc nội dung
  Future<List<Note>> searchNotes(String query) async {
    final response = await http.get(Uri.parse('$baseUrl$_notesEndpoint?q=$query'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Note.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search notes: ${response.statusCode}');
    }
  }

  // Patch - Cập nhật một phần thông tin note
  Future<Note> patchNote(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$_notesEndpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Note.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to patch note: ${response.statusCode}');
    }
  }
}