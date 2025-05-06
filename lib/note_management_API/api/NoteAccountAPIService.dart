import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/NoteAccount.dart';

class NoteAccountAPIService {
  static final NoteAccountAPIService instance = NoteAccountAPIService._init();
  final String baseUrl = 'https://my-json-server.typicode.com/erian674/Note';

  NoteAccountAPIService._init();

  // Create - Thêm account mới
  Future<NoteAccount> createAccount(NoteAccount account) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts'), // Endpoint cho accounts
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(account.toJSON()),
    );

    if (response.statusCode == 201) {
      return NoteAccount.fromJSON(response.body);
    } else {
      throw Exception('Failed to create account: ${response.statusCode}');
    }
  }

  // Read - Đọc tất cả accounts
  Future<List<NoteAccount>> getAllAccounts() async {
    final response = await http.get(Uri.parse('$baseUrl/accounts')); // Endpoint cho accounts

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => NoteAccount.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load accounts: ${response.statusCode}');
    }
  }

  // Read - Đọc account theo id
  Future<NoteAccount?> getAccountById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/accounts/$id')); // Endpoint cho accounts/$id

    if (response.statusCode == 200) {
      return NoteAccount.fromMap(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to get account: ${response.statusCode}');
    }
  }

  // Read - Đọc account theo userId
  Future<NoteAccount?> getAccountByUserId(int userId) async {
    final accounts = await getAllAccounts();
    try {
      return accounts.firstWhere((account) => account.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Update - Cập nhật account
  Future<NoteAccount> updateAccount(NoteAccount account) async {
    final response = await http.put(
      Uri.parse('$baseUrl/accounts/${account.id}'), // Endpoint cho accounts/$id
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(account.toJSON()),
    );

    if (response.statusCode == 200) {
      return NoteAccount.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update account: ${response.statusCode}');
    }
  }

  // Delete - Xoá account
  Future<bool> deleteAccount(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/accounts/$id')); // Endpoint cho accounts/$id

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete account: ${response.statusCode}');
    }
  }

  // Đếm số lượng accounts
  Future<int> countAccounts() async {
    final accounts = await getAllAccounts();
    return accounts.length;
  }

  // Xử lý lỗi chung
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('API error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  // Đăng nhập - Xác thực tài khoản
  Future<NoteAccount?> login(String username, String password) async {
    final accounts = await getAllAccounts();
    try {
      final account = accounts.firstWhere(
              (account) => account.username == username && account.password == password && account.status == 'active'
      );

      // Cập nhật thời gian đăng nhập gần nhất
      account.lastLogin = DateTime.now().toIso8601String();
      await updateAccount(account);

      return account;
    } catch (e) {
      return null;
    }
  }

  // Cập nhật trạng thái tài khoản
  Future<NoteAccount> updateAccountStatus(int id, String status) async {
    return await patchAccount(id, {'status': status});
  }

  // Đổi mật khẩu
  Future<NoteAccount> changePassword(int id, String oldPassword, String newPassword) async {
    final account = await getAccountById(id);

    if (account == null) {
      throw Exception('Account not found');
    }

    if (account.password != oldPassword) {
      throw Exception('Incorrect old password');
    }

    return await patchAccount(id, {'password': newPassword});
  }

  // Kiểm tra tài khoản tồn tại
  Future<bool> isUsernameExists(String username) async {
    final accounts = await getAllAccounts();
    return accounts.any((account) => account.username == username);
  }

  // Patch - Cập nhật một phần thông tin account
  Future<NoteAccount> patchAccount(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/accounts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return NoteAccount.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to patch account: ${response.statusCode}');
    }
  }

  // Lấy danh sách tài khoản theo trạng thái
  Future<List<NoteAccount>> getAccountsByStatus(String status) async {
    final accounts = await getAllAccounts();
    return accounts.where((account) => account.status == status).toList();
  }

  // Reset mật khẩu
  Future<NoteAccount> resetPassword(int id) async {
    final account = await getAccountById(id);
    if (account == null) {
      throw Exception('Account not found');
    }
    // Tạo mật khẩu ngẫu nhiên (đây chỉ là ví dụ, cần cách tạo an toàn hơn)
    final newPassword = 'Reset${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    return patchAccount(id, {'password': newPassword, 'status': 'active'});
  }
}