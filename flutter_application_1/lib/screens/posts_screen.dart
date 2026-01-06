import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import 'post_detail_screen.dart';

class PostsScreen extends StatefulWidget {
  final ApiService apiService;

  const PostsScreen({super.key, required this.apiService});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await widget.apiService.getPosts();
    
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _posts = result['data'] as List<Post>;
      } else {
        _error = result['message'];
      }
    });
  }

  Future<void> _vote(String postId, int vote) async {
    if (!widget.apiService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to vote')),
      );
      return;
    }

    final result = await widget.apiService.votePost(postId, vote);
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vote recorded!')),
      );
      _loadPosts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result['message']}')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, y').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPosts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _posts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No posts yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create your first post!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _posts.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: InkWell(
                            onTap: () async {
                              final needsRefresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailScreen(
                                    post: post,
                                    apiService: widget.apiService,
                                  ),
                                ),
                              );
                              if (needsRefresh == true) {
                                _loadPosts();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Vote section
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_upward),
                                          onPressed: () => _vote(post.id, 1),
                                          color: Colors.green,
                                        ),
                                        Text(
                                          '${post.voteCount}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: post.voteCount > 0
                                                ? Colors.green
                                                : post.voteCount < 0
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_downward),
                                          onPressed: () => _vote(post.id, -1),
                                          color: Colors.red,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    // Content section
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            post.content,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 12),
                                          // Tags
                                          if (post.tags.isNotEmpty)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: post.tags.map((tag) {
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: Colors.blue.shade200),
                                                  ),
                                                  child: Text(
                                                    tag,
                                                    style: TextStyle(
                                                      color: Colors.blue.shade700,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          const SizedBox(height: 12),
                                          // Author and date
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.person, size: 16, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    post.authorName,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                _formatDate(post.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ),
                        );
                      },
                    ),
    );
  }
}
