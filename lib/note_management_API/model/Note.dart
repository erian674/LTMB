import 'dart:convert';

class Note {
  int? id;
  String title;
  String content;
  int priority;
  DateTime createdAt;
  DateTime modifiedAt;
  List<String>? tags;
  String? color;
  bool? isCompleted;
  String? imagePath;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
    this.isCompleted = false,
    this.imagePath,
  });

  // Named constructor từ JSON
  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        content = json['content'],
        priority = json['priority'],
        createdAt = DateTime.parse(json['createdAt']),
        modifiedAt = DateTime.parse(json['modifiedAt']),
        tags = (json['tags'] as List<dynamic>?)?.cast<String>(),
        color = json['color'],
        isCompleted = json['isCompleted'] == 1,
        imagePath = json['imagePath'];

  // Chuyển đối tượng thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags,
      'color': color,
      'isCompleted': isCompleted == true ? 1 : 0,
      'imagePath': imagePath,
    };
  }

  // Tạo đối tượng từ Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      priority: map['priority'] ?? 1,
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: DateTime.parse(map['modifiedAt']),
      tags: (map['tags'] as List<dynamic>?)?.cast<String>(),
      color: map['color'],
      isCompleted: map['isCompleted'] == 1,
      imagePath: map['imagePath'],
    );
  }

  // Tạo bản sao với một số thuộc tính được cập nhật
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
    bool? isCompleted,
    String? imagePath,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, priority: $priority, '
        'createdAt: $createdAt, modifiedAt: $modifiedAt, tags: $tags, '
        'color: $color, isCompleted: $isCompleted, imagePath: $imagePath}';
  }

  // Chuyển đối tượng thành JSON string
  String toJson() => json.encode(toMap());

  // Tạo đối tượng từ JSON string
  factory Note.fromJsonString(String str) => Note.fromJson(json.decode(str));
}