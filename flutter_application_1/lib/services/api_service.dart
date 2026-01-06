import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/answer.dart';
import '../models/comment.dart';

export '../models/answer.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  String? _token;
  String? _userId;

  String? get currentUserId => _userId;

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['user']['id'];
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['user']['id'];
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> createPost(String title, String content, List<String> tags) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'tags': tags,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final posts = data.map((json) => Post.fromJson(json)).toList();
        return {'success': true, 'data': posts};
      } else {
        return {'success': false, 'message': 'Failed to load posts'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> votePost(String postId, int vote) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/vote'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'vote': vote}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse(baseUrl.replaceAll('/api', '')));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getAnswers(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/answers/post/$postId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final answers = data.map((json) => Answer.fromJson(json)).toList();
        return {'success': true, 'data': answers};
      } else {
        return {'success': false, 'message': 'Failed to load answers'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> createAnswer(String postId, String body) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/answers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'post': postId,
          'body': body,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateAnswer(String answerId, String body) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/answers/$answerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'body': body}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> upvoteAnswer(String answerId) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/answers/$answerId/upvote'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> downvoteAnswer(String answerId) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/answers/$answerId/downvote'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getCommentsForPost(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments/post/$postId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final comments = data.map((json) => Comment.fromJson(json)).toList();
        return {'success': true, 'data': comments};
      } else {
        return {'success': false, 'message': 'Failed to load comments'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getCommentsForAnswer(String answerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments/answer/$answerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final comments = data.map((json) => Comment.fromJson(json)).toList();
        return {'success': true, 'data': comments};
      } else {
        return {'success': false, 'message': 'Failed to load comments'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> createComment({
    required String content,
    required String type,
    String? postId,
    String? answerId,
  }) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final body = <String, dynamic>{
        'content': content,
        'type': type,
      };

      if (postId != null) body['post'] = postId;
      if (answerId != null) body['answer'] = answerId;

      final response = await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> upvoteComment(String commentId) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/comments/$commentId/upvote'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAnswer(String answerId) async {
    try {
      if (_token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/answers/$answerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get Comment Statistics (Aggregate API)
  Future<Map<String, dynamic>> getCommentStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments/stats/aggregate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load stats'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get Detailed Comments (Populate API)
  Future<Map<String, dynamic>> getDetailedComments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments/stats/detailed'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load detailed comments'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  bool get isAuthenticated => _token != null;

  void logout() {
    _token = null;
    _userId = null;
  }
}
