import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';
import 'dashboard_screen.dart';
import 'persona_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  double _page = 0.0;
  final List<Destination> _destinations = Destination.mockDestinations;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(_onScroll);

    // Header fade-in animation optimized for 120Hz
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    _headerAnimationController.forward();
  }

  void _onScroll() {
    setState(() {
      _page = _pageController.page ?? 0.0;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _navigateToPlanning(Destination destination) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PersonaSelectionScreen(destination: destination),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Ultra-smooth page transition optimized for 120Hz
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: Curves.easeOutCubic),
          );
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated header with fade-in
            FadeTransition(
              opacity: _headerFadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _headerAnimationController,
                  curve: Curves.easeOutCubic,
                )),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Where to next?',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Swipe to explore your next adventure',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.luggage, color: Colors.white),
                          tooltip: 'My Trips',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Card carousel with ultra-smooth 120Hz animations
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _destinations.length,
                // Custom physics for buttery-smooth 120Hz scrolling
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                itemBuilder: (context, index) {
                  // Calculate relative position of card for parallax
                  final double relativePosition = index - _page;

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: relativePosition),
                    duration: const Duration(milliseconds: 16), // ~120Hz
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedPosition, child) {
                      // Scale effect: Center card is 1.0, side cards 0.9
                      // Ultra-smooth interpolation for 120Hz
                      double scale = 1.0 - (animatedPosition.abs() * 0.1);
                      scale = scale.clamp(0.85, 1.0);

                      // Opacity effect for depth with smooth falloff
                      double opacity = 1.0 - (animatedPosition.abs() * 0.3);
                      opacity = opacity.clamp(0.5, 1.0);

                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: DestinationCard(
                            destination: _destinations[index],
                            onTap: () =>
                                _navigateToPlanning(_destinations[index]),
                            parallaxOffset: animatedPosition,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
