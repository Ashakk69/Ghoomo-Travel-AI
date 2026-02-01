import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../utils/theme_constants.dart';
import '../services/preferences_service.dart';
import '../services/share_service.dart';
import 'ai_badge.dart';
import 'comments_sheet.dart';

class FeedItem extends StatefulWidget {
  final Destination destination;
  final VoidCallback onPlanThis;
  final String aiTip;
  final AIBadgeType tipType;

  const FeedItem({
    super.key,
    required this.destination,
    required this.onPlanThis,
    this.aiTip = '',
    this.tipType = AIBadgeType.tip,
  });

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  final PreferencesService _prefsService = PreferencesService();
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // Random like count for demo
    _likeCount = (widget.destination.name.length * 100) % 3000 + 500;
    _loadStates();
  }

  Future<void> _loadStates() async {
    final liked = await _prefsService.isDestinationLiked(widget.destination.id);
    final saved = await _prefsService.isDestinationSaved(widget.destination.id);

    if (mounted) {
      setState(() {
        _isLiked = liked;
        _isSaved = saved;
      });
    }
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    await _prefsService.toggleLikedDestination(widget.destination.id);
  }

  Future<void> _toggleSave() async {
    setState(() {
      _isSaved = !_isSaved;
    });

    await _prefsService.toggleSavedDestination(widget.destination.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved ? 'Saved to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: _isSaved ? Colors.green : Colors.grey[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 12),

          // Main Image Card
          _buildImageCard(),
          const SizedBox(height: 12),

          // AI Tip
          if (widget.aiTip.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AIBadge(
                type: widget.tipType,
                message: widget.aiTip,
              ),
            ),
          const SizedBox(height: 12),

          // Interaction Bar
          _buildInteractionBar(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  GhoomoColors.primary,
                  GhoomoColors.primaryDark,
                ],
              ),
              border: Border.all(
                color: GhoomoColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.travel_explore,
              color: GhoomoColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Name and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Ghoomo Explorer',
                      style: GhoomoTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      color: GhoomoColors.primary,
                      size: 16,
                    ),
                  ],
                ),
                Text(
                  '@ghoomo_ai · 2h ago',
                  style: GhoomoTextStyles.caption.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // More button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GhoomoRadius.large),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: Image.asset(
                  widget.destination.imageAsset,
                  fit: BoxFit.cover,
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // Save button (top right)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _toggleSave,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: _isSaved ? GhoomoColors.primary : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Bottom content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                              'Under \$${widget.destination.estimatedCost}'),
                          _buildChip('7 Days'),
                          _buildChip(
                            widget.destination.category,
                            isPrimary: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        widget.destination.name,
                        style: GhoomoTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.destination.country,
                            style: GhoomoTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? GhoomoColors.primary
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(GhoomoRadius.full),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: isPrimary ? GhoomoShadows.medium : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: GhoomoTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
          color: isPrimary ? GhoomoColors.accent : Colors.white,
        ),
      ),
    );
  }

  Widget _buildInteractionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: _toggleLike,
            child: Row(
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.pink : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatCount(_likeCount),
                  style: GhoomoTextStyles.caption.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Comment button
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: CommentsSheet(destination: widget.destination),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatCount(48),
                  style: GhoomoTextStyles.caption.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Share button
          IconButton(
            onPressed: () => ShareService.shareDestination(widget.destination),
            icon: const Icon(
              Icons.share_outlined,
              color: Colors.grey,
              size: 24,
            ),
          ),

          const Spacer(),

          // Plan This button
          ElevatedButton(
            onPressed: widget.onPlanThis,
            style: ElevatedButton.styleFrom(
              backgroundColor: GhoomoColors.primary,
              foregroundColor: GhoomoColors.accent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GhoomoRadius.full),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Plan This',
                  style: GhoomoTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GhoomoColors.accent,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
