class Answer {
  final String id;
  final String body;
  final dynamic author;
  final String post;
  final Votes votes;
  final bool isAccepted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Answer({
    required this.id,
    required this.body,
    required this.author,
    required this.post,
    required this.votes,
    required this.isAccepted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['_id'] ?? '',
      body: json['body'] ?? '',
      author: json['author'],
      post: json['post'] ?? '',
      votes: Votes.fromJson(json['votes'] ?? {}),
      isAccepted: json['isAccepted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'post': post,
    };
  }

  String get authorName {
    if (author is Map) {
      return author['username'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  String? get authorId {
    if (author is String) {
      return author;
    } else if (author is Map && author['_id'] != null) {
      return author['_id'];
    }
    return null;
  }
}

class Votes {
  final int upvotes;
  final int downvotes;

  Votes({
    required this.upvotes,
    required this.downvotes,
  });

  factory Votes.fromJson(Map<String, dynamic> json) {
    return Votes(
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
    );
  }

  int get total => upvotes - downvotes;
}
