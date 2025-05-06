class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? avatar;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'avatar': avatar ?? '',
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isAdmin': isAdmin ? 1 : 0,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      avatar: map['avatar'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
      isAdmin: map['isAdmin'] == 1,
    );
  }
  // Thêm hàm copyWith
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}