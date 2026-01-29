import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../models/destination.dart';
import '../models/user_persona.dart';
import '../models/currency.dart';
import '../services/ai_trip_generator.dart';
import 'itinerary_screen.dart';

class LoadingScreen extends StatefulWidget {
  final Destination destination;
  final UserPersona persona;
  final Currency currency;
  final double budgetUSD;
  final int days;
  final Set<String> interests;

  const LoadingScreen({
    super.key,
    required this.destination,
    required this.persona,
    required this.currency,
    required this.budgetUSD,
    required this.days,
    required this.interests,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Generate AI itinerary
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        // Generate personalized itinerary
        final itinerary = AITripGenerator.generateItinerary(
          destination: widget.destination,
          days: widget.days,
          budgetUSD: widget.budgetUSD,
          interests: widget.interests,
          persona: widget.persona,
        );

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ItineraryScreen(
              destination: widget.destination,
              itinerary: itinerary,
              currency: widget.currency,
              budget: widget.budgetUSD,
              days: widget.days,
              interests: widget.interests,
              persona: widget.persona,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Plane Animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Radar rings
                    _buildRing(100 * _controller.value),
                    _buildRing(100 * ((_controller.value + 0.5) % 1.0)),

                    // Rotating Plane
                    Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: Container(
                        height: 60,
                        width: 60,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.flight,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 48),
            Text(
              'Crafting your trip to ${widget.destination.name}...',
              style: GoogleFonts.outfit(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Analyzing preferences...',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(double radius) {
    return Container(
      width: radius * 3,
      height: radius * 3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context)
              .primaryColor
              .withValues(alpha: 1 - (radius / 100).clamp(0.0, 1.0)),
          width: 2,
        ),
      ),
    );
  }
}
