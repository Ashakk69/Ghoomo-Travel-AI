import 'package:flutter/material.dart';
import '../models/destination.dart';
import 'package:google_fonts/google_fonts.dart';
import 'liquid_glass.dart';

class DestinationCard extends StatefulWidget {
  final Destination destination;
  final VoidCallback onTap;
  final double parallaxOffset;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.parallaxOffset = 0.0,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Ultra-smooth animation controller optimized for 120Hz
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeOutCubic, // Smooth curve for 120Hz
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) {
        _hoverController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Hero(
          tag: 'destination-${widget.destination.id}',
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Parallax Image Background with ultra-smooth interpolation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widget.parallaxOffset),
                  duration: const Duration(milliseconds: 16), // ~120Hz update
                  curve: Curves.easeOutCubic,
                  builder: (context, offset, child) {
                    return Transform.scale(
                      scale: 1.1, // Slight zoom to allow parallax movement
                      child: Container(
                        alignment: Alignment(
                            offset * 0.5, 0), // Subtle horizontal parallax
                        child: Image.asset(
                          widget.destination.imageAsset,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.white54),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                // Gradient Overlay for Readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.4, 0.7, 1.0],
                    ),
                  ),
                ),

                // Content with Liquid Glass Effects
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating badge with liquid glass effect
                      LiquidGlass(
                        borderRadius: 20,
                        blur: 12,
                        opacity: 0.15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Color(0xFFFFD700), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                widget.destination.rating.toString(),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Destination name with smooth fade-in
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: child,
                          );
                        },
                        child: Text(
                          widget.destination.name,
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.destination.country.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description with liquid glass background
                      LiquidGlass(
                        borderRadius: 16,
                        blur: 10,
                        opacity: 0.1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            widget.destination.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.95),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
