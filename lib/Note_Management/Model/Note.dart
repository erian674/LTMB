class Note {
  final int? id;
  final String title;
  final String content;
  final int priority; // 1: Thấp, 2: Trung bình, 3: Cao
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String>? tags;
  final String? color; // Dạng hex hoặc tên màu
  final int isDone;
  final String? imagePath;

  // Constructor chính
  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
    this.isDone = 0,
    this.imagePath,
  });

  // Named constructor: Tạo từ Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] is int
          ? map['createdAt']
          : int.tryParse(map['createdAt']) ?? 0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(map['modifiedAt'] is int
          ? map['modifiedAt']
          : int.tryParse(map['modifiedAt']) ?? 0),
      tags: map['tags'] != null
          ? map['tags'].toString().split(',')
          : [],
      color: map['color'],
      isDone: map['isDone'] ?? 0,
      imagePath: map['imagePath'],
    );
  }

  // Chuyển đối tượng thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'modifiedAt': modifiedAt.millisecondsSinceEpoch,
      'tags': tags?.join(','),
      'color': color,
      'isDone': isDone,
      'imagePath': imagePath,
    };
  }

  // Tạo bản sao với một số thuộc tính thay đổi
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
    int? isDone,
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
      isDone: isDone ?? this.isDone,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, priority: $priority, '
        'createdAt: $createdAt, modifiedAt: $modifiedAt, tags: $tags, '
        'color: $color, isDone: $isDone, imagePath: $imagePath)';
  }
}