import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';
import '../models/destination.dart';

class CommentsSheet extends StatefulWidget {
  final Destination destination;

  const CommentsSheet({super.key, required this.destination});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock comments
  final List<Map<String, dynamic>> _comments = [
    {
      'user': 'Sarah Jenkins',
      'avatar': null, // Use Initials
      'text': 'This looks absolutely stunning! Adding to my bucket list.',
      'time': '2h ago',
      'likes': 12,
      'isLiked': false,
    },
    {
      'user': 'Mike Chen',
      'avatar': null,
      'text': 'Been there last year. The food is incredible!',
      'time': '5h ago',
      'likes': 8,
      'isLiked': true,
    },
    {
      'user': 'Travel bug',
      'avatar': null,
      'text': 'What is the best time of year to visit?',
      'time': '1d ago',
      'likes': 3,
      'isLiked': false,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.insert(0, {
        'user': 'You',
        'avatar': null,
        'text': _commentController.text.trim(),
        'time': 'Just now',
        'likes': 0,
        'isLiked': false,
      });
      _commentController.clear();
    });

    // Scroll to top
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleLike(int index) {
    setState(() {
      final comment = _comments[index];
      final isLiked = comment['isLiked'] as bool;
      comment['isLiked'] = !isLiked;
      comment['likes'] = (comment['likes'] as int) + (isLiked ? -1 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GhoomoColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GhoomoRadius.large),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments',
                  style: GhoomoTextStyles.h3,
                ),
                Text(
                  '${_comments.length} comments',
                  style: GhoomoTextStyles.caption.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),

          // Comments List
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return _buildCommentItem(comment, index);
              },
            ),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: GhoomoColors.backgroundDark,
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: GhoomoColors.primary,
                  child: const Icon(Icons.person,
                      size: 20, color: GhoomoColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: GhoomoColors.surfaceDark,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send_rounded),
                  color: GhoomoColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.primaries[index % Colors.primaries.length],
          child: Text(
            (comment['user'] as String)[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment['user'],
                    style: GhoomoTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment['time'],
                    style: GhoomoTextStyles.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment['text'],
                style: GhoomoTextStyles.bodySmall.copyWith(
                  height: 1.4,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {}, // Reply functionality omitted for now
                    child: Text(
                      'Reply',
                      style: GhoomoTextStyles.caption.copyWith(
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () => _toggleLike(index),
              child: Icon(
                comment['isLiked'] ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: comment['isLiked'] ? Colors.pink : Colors.white38,
              ),
            ),
            const SizedBox(height: 2),
            if ((comment['likes'] as int) > 0)
              Text(
                '${comment['likes']}',
                style: GhoomoTextStyles.caption.copyWith(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
