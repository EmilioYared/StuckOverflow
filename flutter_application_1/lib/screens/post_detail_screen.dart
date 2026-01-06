import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import '../models/answer.dart';
import '../models/comment.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final ApiService apiService;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.apiService,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  List<Answer> _answers = [];
  List<Comment> _postComments = [];
  Map<String, List<Comment>> _answerComments = {};
  bool _isLoading = true;
  final _answerController = TextEditingController();
  final _commentController = TextEditingController();
  final _editAnswerController = TextEditingController();
  bool _isSubmitting = false;
  String? _commentingOn;
  String? _editingAnswerId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _commentController.dispose();
    _editAnswerController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAnswers(),
      _loadPostComments(),
    ]);
  }

  Future<void> _loadAnswers() async {
    setState(() => _isLoading = true);

    final result = await widget.apiService.getAnswers(widget.post.id);

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _answers = result['data'] as List<Answer>;
        for (var answer in _answers) {
          _loadAnswerComments(answer.id);
        }
      }
    });
  }

  Future<void> _loadPostComments() async {
    final result = await widget.apiService.getCommentsForPost(widget.post.id);
    if (result['success']) {
      setState(() {
        _postComments = result['data'] as List<Comment>;
      });
    }
  }

  Future<void> _loadAnswerComments(String answerId) async {
    final result = await widget.apiService.getCommentsForAnswer(answerId);
    if (result['success']) {
      setState(() {
        _answerComments[answerId] = result['data'] as List<Comment>;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an answer')),
      );
      return;
    }

    if (!widget.apiService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to answer')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await widget.apiService.createAnswer(
      widget.post.id,
      _answerController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (result['success']) {
      _answerController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer posted!')),
      );
      _loadAnswers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result['message']}')),
      );
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    if (!widget.apiService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to comment')),
      );
      return;
    }

    final result = await widget.apiService.createComment(
      content: _commentController.text.trim(),
      type: _commentingOn == 'post' ? 'question' : 'answer',
      postId: _commentingOn == 'post' ? widget.post.id : null,
      answerId: _commentingOn != 'post' ? _commentingOn : null,
    );

    if (result['success']) {
      _commentController.clear();
      final target = _commentingOn;
      setState(() => _commentingOn = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added!')),
      );
      
      if (target == 'post') {
        _loadPostComments();
      } else if (target != null) {
        _loadAnswerComments(target);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result['message']}')),
      );
    }
  }

  void _showCommentInput(String target) {
    setState(() {
      _commentingOn = target;
      _commentController.clear();
    });
  }

  void _cancelComment() {
    setState(() {
      _commentingOn = null;
      _commentController.clear();
    });
  }

  Future<void> _upvoteAnswer(String answerId) async {
    if (!widget.apiService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to vote')),
      );
      return;
    }

    final result = await widget.apiService.upvoteAnswer(answerId);
    if (result['success']) {
      _loadAnswers();
    }
  }

  Future<void> _downvoteAnswer(String answerId) async {
    if (!widget.apiService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to vote')),
      );
      return;
    }

    final result = await widget.apiService.downvoteAnswer(answerId);
    if (result['success']) {
      _loadAnswers();
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure? This will delete the post, all answers, and all comments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await widget.apiService.deletePost(widget.post.id);
    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    }
  }

  Future<void> _deleteAnswer(String answerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Answer'),
        content: const Text(
          'Are you sure? This will also delete all comments on this answer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await widget.apiService.deleteAnswer(answerId);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer deleted successfully')),
      );
      _loadAnswers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result['message']}')),
      );
    }
  }

  Future<void> _deleteComment(String commentId, {bool isPostComment = false}) async {
    final result = await widget.apiService.deleteComment(commentId);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted')),
      );
      if (isPostComment) {
        _loadPostComments();
      } else {
        for (var answer in _answers) {
          _loadAnswerComments(answer.id);
        }
      }
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
    final bool isPostAuthor = widget.apiService.currentUserId == widget.post.authorId;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
        actions: [
          if (isPostAuthor)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deletePost(),
              tooltip: 'Delete Post',
            ),
        ],
      ),
      body: Column(
        children: [
          // Post Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Card
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vote section
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_upward),
                                    onPressed: () {},
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    '${widget.post.voteCount}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: widget.post.voteCount > 0
                                          ? Colors.green
                                          : widget.post.voteCount < 0
                                              ? Colors.red
                                              : Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_downward),
                                    onPressed: () {},
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.post.title,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.post.content,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    if (widget.post.tags.isNotEmpty)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: widget.post.tags.map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: Colors.blue.shade200),
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
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              widget.post.authorName,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          _formatDate(widget.post.createdAt),
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

                  // Post Comments Section
                  if (_postComments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._postComments.map((comment) => _buildCommentWidget(comment)),
                        ],
                      ),
                    ),
                  
                  // Add Comment Button for Post
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextButton.icon(
                      onPressed: () => _showCommentInput('post'),
                      icon: const Icon(Icons.comment, size: 16),
                      label: const Text('Add comment'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Answers Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '${_answers.length} Answer${_answers.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Answers List
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_answers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No answers yet. Be the first to answer!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _answers.length,
                      itemBuilder: (context, index) {
                        final answer = _answers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: answer.isAccepted
                              ? Colors.green.shade50
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Vote section
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_upward),
                                      onPressed: () => _upvoteAnswer(answer.id),
                                      color: Colors.green,
                                      iconSize: 20,
                                    ),
                                    Text(
                                      '${answer.votes.total}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: answer.votes.total > 0
                                            ? Colors.green
                                            : answer.votes.total < 0
                                                ? Colors.red
                                                : Colors.grey,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_downward),
                                      onPressed: () => _downvoteAnswer(answer.id),
                                      color: Colors.red,
                                      iconSize: 20,
                                    ),
                                    if (answer.isAccepted)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_editingAnswerId == answer.id)
                                        Column(
                                          children: [
                                            TextField(
                                              controller: _editAnswerController,
                                              maxLines: 5,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: 'Edit your answer...',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _editingAnswerId = null;
                                                      _editAnswerController.clear();
                                                    });
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    if (_editAnswerController.text.trim().isEmpty) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Answer cannot be empty')),
                                                      );
                                                      return;
                                                    }
                                                    final result = await widget.apiService.updateAnswer(
                                                      answer.id,
                                                      _editAnswerController.text.trim(),
                                                    );
                                                    if (result['success']) {
                                                      setState(() {
                                                        _editingAnswerId = null;
                                                        _editAnswerController.clear();
                                                      });
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Answer updated!')),
                                                      );
                                                      _loadAnswers();
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Error: ${result['message']}')),
                                                      );
                                                    }
                                                  },
                                                  child: const Text('Save'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      else
                                        Text(
                                          answer.body,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.person,
                                                  size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                answer.authorName,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                _formatDate(answer.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              if (widget.apiService.currentUserId == answer.authorId && _editingAnswerId != answer.id)
                                                IconButton(
                                                  icon: const Icon(Icons.edit, size: 16),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  color: Colors.blue,
                                                  onPressed: () {
                                                    setState(() {
                                                      _editingAnswerId = answer.id;
                                                      _editAnswerController.text = answer.body;
                                                    });
                                                  },
                                                  tooltip: 'Edit Answer',
                                                ),
                                              if (widget.apiService.currentUserId == answer.authorId && _editingAnswerId != answer.id)
                                                IconButton(
                                                  icon: const Icon(Icons.delete, size: 16),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  color: Colors.red,
                                                  onPressed: () => _deleteAnswer(answer.id),
                                                  tooltip: 'Delete Answer',
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      // Answer Comments
                                      if (_answerComments[answer.id]?.isNotEmpty ?? false)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            ..._answerComments[answer.id]!.map((comment) => 
                                              _buildCommentWidget(comment, isAnswerComment: true)),
                                          ],
                                        ),
                                      
                                      // Add Comment Button for Answer
                                      TextButton.icon(
                                        onPressed: () => _showCommentInput(answer.id),
                                        icon: const Icon(Icons.comment, size: 14),
                                        label: const Text('Add comment'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          textStyle: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Comment Input (shows when _commentingOn is set)
          if (_commentingOn != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(top: BorderSide(color: Colors.blue.shade200)),
              ),
              padding: const EdgeInsets.all(12.0),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Add comment to ${_commentingOn == "post" ? "question" : "answer"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _cancelComment,
                          icon: const Icon(Icons.close, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Write a comment...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            maxLines: 2,
                            minLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _submitComment,
                          icon: const Icon(Icons.send, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Answer Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        hintText: 'Write your answer...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSubmitting ? null : _submitAnswer,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    iconSize: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentWidget(Comment comment, {bool isAnswerComment = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isAnswerComment ? 4 : 6,
        horizontal: isAnswerComment ? 8 : 0,
      ),
      margin: EdgeInsets.only(bottom: isAnswerComment ? 2 : 4, left: isAnswerComment ? 16 : 0),
      decoration: BoxDecoration(
        color: isAnswerComment ? Colors.grey.shade50 : null,
        borderRadius: isAnswerComment ? BorderRadius.circular(4) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    if (widget.apiService.isAuthenticated) {
                      await widget.apiService.upvoteComment(comment.id);
                      // Refresh the appropriate comments list
                      if (isAnswerComment) {
                        // Find which answer this comment belongs to
                        for (var answer in _answers) {
                          if (_answerComments[answer.id]?.any((c) => c.id == comment.id) ?? false) {
                            await _loadAnswerComments(answer.id);
                            break;
                          }
                        }
                      } else {
                        await _loadPostComments();
                      }
                    }
                  },
                  child: Icon(Icons.arrow_upward, size: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 4),
                Text(
                  '${comment.score}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isAnswerComment ? 12 : 13,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: comment.content),
                      const TextSpan(text: ' – '),
                      TextSpan(
                        text: comment.authorName,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (comment.authorReputation > 0)
                        TextSpan(
                          text: ' (${comment.authorReputation})',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      TextSpan(
                        text: ' ${_formatDate(comment.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                      if (comment.isEdited)
                        TextSpan(
                          text: ' (edited)',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Delete button for comment author
          if (widget.apiService.currentUserId == comment.authorId)
            InkWell(
              onTap: () => _deleteComment(
                comment.id,
                isPostComment: !isAnswerComment,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.red.shade400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
