class Vote {
  final String user;
  final int vote;

  Vote({
    required this.user,
    required this.vote,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      user: json['user'] ?? '',
      vote: json['vote'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'vote': vote,
    };
  }
}

class Post {
  final String id;
  final String title;
  final String content;
  final dynamic author; // Can be String (ID) or Map (populated User)
  final List<String> tags;
  final List<Vote> votes;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.tags,
    required this.votes,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'],
      tags: List<String>.from(json['tags'] ?? []),
      votes: (json['votes'] as List<dynamic>?)
              ?.map((v) => Vote.fromJson(v))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
    };
  }

  int get voteCount {
    return votes.fold(0, (sum, vote) => sum + vote.vote);
  }

  String get authorName {
    if (author is Map) {
      return author['username'] ?? 'Unknown';
    }
    return 'Unknown';
  }
}
