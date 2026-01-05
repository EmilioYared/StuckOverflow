class Comment {
  final String id;
  final String content;
  final String status;
  final String type;
  final int score;
  final bool isEdited;
  final List<String> mentions;
  final dynamic author;
  final String? post;
  final String? answer;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.content,
    required this.status,
    required this.type,
    required this.score,
    required this.isEdited,
    required this.mentions,
    required this.author,
    this.post,
    this.answer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 'approved',
      type: json['type'] ?? 'general',
      score: json['score'] ?? 0,
      isEdited: json['isEdited'] ?? false,
      mentions: List<String>.from(json['mentions'] ?? []),
      author: json['author'],
      post: json['post'],
      answer: json['answer'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type,
      'post': post,
      'answer': answer,
      'mentions': mentions,
    };
  }

  String get authorName {
    if (author is Map) {
      return author['username'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  int get authorReputation {
    if (author is Map) {
      return author['reputation'] ?? 0;
    }
    return 0;
  }
  String? get authorId {
    if (author is String) {
      return author;
    } else if (author is Map && author['_id'] != null) {
      return author['_id'];
    }
    return null;
  }}
