import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video.dart';
import '../models/video_comment.dart';
import '../providers/video_comment_provider.dart';
import '../providers/auth_state.dart';

class VideoCommentsSheet extends ConsumerStatefulWidget {
  final Video video;

  const VideoCommentsSheet({
    super.key,
    required this.video,
  });

  @override
  ConsumerState<VideoCommentsSheet> createState() => _VideoCommentsSheetState();
}

class _VideoCommentsSheetState extends ConsumerState<VideoCommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyToCommentId;
  String? _replyToUsername;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      await ref.read(videoCommentControllerProvider.notifier).addComment(
        widget.video.id,
        text,
        parentCommentId: _replyToCommentId,
      );
      
      if (mounted) {
        _commentController.clear();
        setState(() {
          _replyToCommentId = null;
          _replyToUsername = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to post comment. Please try again later.')),
        );
      }
    }
  }

  void _showReplies(VideoComment comment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _CommentRepliesView(
          comment: comment,
          scrollController: scrollController,
          onReply: (commentId, username) {
            Navigator.pop(context);
            setState(() {
              _replyToCommentId = commentId;
              _replyToUsername = username;
              _commentController.text = '@$username ';
            });
            _commentController.selection = TextSelection.fromPosition(
              TextPosition(offset: _commentController.text.length),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.invalidate(videoCommentsProvider(widget.video.id));
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(videoCommentsProvider(widget.video.id));
    final user = ref.watch(authStateProvider).value;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Comments list
            Expanded(
              child: comments.when(
                data: (commentsList) => commentsList.isEmpty
                    ? _buildErrorView('No comments yet.\nBe the first to comment!')
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: commentsList.length,
                        itemBuilder: (context, index) => _CommentTile(
                          comment: commentsList[index],
                          currentUserId: user?.id,
                          onReply: () => _showReplies(commentsList[index]),
                          onDelete: user?.id == commentsList[index].userId
                              ? () => ref.read(videoCommentControllerProvider.notifier)
                                  .deleteComment(commentsList[index])
                              : null,
                        ),
                      ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => _buildErrorView(
                  'Unable to load comments.\nPlease check your connection.',
                ),
              ),
            ),
            // Comment input
            if (user != null) ...[
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: _replyToUsername != null
                              ? 'Reply to @$_replyToUsername'
                              : 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submitComment,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Sign in to comment',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends ConsumerWidget {
  final VideoComment comment;
  final String? currentUserId;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: comment.userProfileImage != null
                ? NetworkImage(comment.userProfileImage!)
                : null,
            child: comment.userProfileImage == null
                ? Text(comment.userDisplayName?[0].toUpperCase() ?? '?')
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userDisplayName ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(comment.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(videoCommentControllerProvider.notifier)
                          .toggleCommentLike(comment.id, true),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: comment.likeCount > 0 ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.likeCount.toString(),
                            style: TextStyle(
                              color: comment.likeCount > 0 ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onReply,
                      child: Row(
                        children: [
                          const Icon(Icons.reply, size: 16),
                          const SizedBox(width: 4),
                          Text(comment.replies.toString()),
                        ],
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(Icons.delete, size: 16),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class _CommentRepliesView extends ConsumerWidget {
  final VideoComment comment;
  final ScrollController scrollController;
  final void Function(String commentId, String username) onReply;

  const _CommentRepliesView({
    required this.comment,
    required this.scrollController,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replies = ref.watch(commentRepliesProvider(comment.id));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Parent comment
          _CommentTile(
            comment: comment,
            currentUserId: ref.watch(authStateProvider).value?.id,
            onReply: () => onReply(comment.id, comment.userDisplayName ?? 'Anonymous'),
          ),
          const Divider(),
          // Replies
          Expanded(
            child: replies.when(
              data: (repliesList) => ListView.builder(
                controller: scrollController,
                itemCount: repliesList.length,
                itemBuilder: (context, index) => _CommentTile(
                  comment: repliesList[index],
                  currentUserId: ref.watch(authStateProvider).value?.id,
                  onReply: () => onReply(
                    comment.id,
                    repliesList[index].userDisplayName ?? 'Anonymous',
                  ),
                  onDelete: ref.watch(authStateProvider).value?.id == repliesList[index].userId
                      ? () => ref.read(videoCommentControllerProvider.notifier)
                          .deleteComment(repliesList[index])
                      : null,
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading replies: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 