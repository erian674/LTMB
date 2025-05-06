import 'dart:convert';

class NoteAccount {
  int? id;
  int userId;
  String username;
  String password;
  String status;
  String? lastLogin;
  String createdAt;

  NoteAccount({
    this.id,
    required this.userId,
    required this.username,
    required this.password,
    required this.status,
    this.lastLogin,
    required this.createdAt,
  });

  // Tạo NoteAccount từ Map
  factory NoteAccount.fromMap(Map<String, dynamic> map) {
    return NoteAccount(
      id: map['id'],
      userId: map['userId'],
      username: map['username'],
      password: map['password'],
      status: map['status'],
      lastLogin: map['lastLogin'],
      createdAt: map['createdAt'],
    );
  }

  // Tạo NoteAccount từ JSON string
  factory NoteAccount.fromJSON(String source) {
    return NoteAccount.fromMap(jsonDecode(source));
  }

  // Chuyển đổi NoteAccount thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'password': password,
      'status': status,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
    };
  }

  // Chuyển đổi NoteAccount thành JSON string
  String toJSON() {
    return jsonEncode(toMap());
  }

  // Tạo bản sao của NoteAccount với một số thuộc tính được cập nhật
  NoteAccount copyWith({
    int? id,
    int? userId,
    String? username,
    String? password,
    String? status,
    String? lastLogin,
    String? createdAt,
  }) {
    return NoteAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NoteAccount(id: $id, userId: $userId, username: $username, status: $status, lastLogin: $lastLogin, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteAccount &&
        other.id == id &&
        other.userId == userId &&
        other.username == username &&
        other.password == password &&
        other.status == status &&
        other.lastLogin == lastLogin &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    username.hashCode ^
    password.hashCode ^
    status.hashCode ^
    lastLogin.hashCode ^
    createdAt.hashCode;
  }
}