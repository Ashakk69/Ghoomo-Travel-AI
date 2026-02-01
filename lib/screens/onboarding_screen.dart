import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GhoomoColors.primary,
              const Color(0xFFFFBF00), // Brighter yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Status bar area
              const SizedBox(height: 40),

              // Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Hero illustration
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Decorative sparkles
                          Positioned(
                            top: 60,
                            right: 40,
                            child: Icon(
                              Icons.auto_awesome,
                              color: GhoomoColors.accent.withOpacity(0.8),
                              size: 40,
                            ),
                          ),
                          Positioned(
                            bottom: 120,
                            left: 30,
                            child: Icon(
                              Icons.star,
                              color: GhoomoColors.accent.withOpacity(0.6),
                              size: 24,
                            ),
                          ),

                          // Main image
                          Center(
                            child: Transform.rotate(
                              angle: -0.035, // ~-2 degrees
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                height:
                                    MediaQuery.of(context).size.width * 0.75,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(48),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.05),
                                    width: 4,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(44),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          GhoomoColors.primary.withOpacity(0.4),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.flight_takeoff,
                                      size: 120,
                                      color:
                                          GhoomoColors.accent.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Text content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Beta badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: GhoomoColors.accent.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(GhoomoRadius.full),
                              border: Border.all(
                                color: GhoomoColors.accent.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'GHOOMO-AI BETA',
                              style: TextStyle(
                                fontFamily: GhoomoTextStyles.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: GhoomoColors.accent,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          Text(
                            'Plan smarter.\nTravel better.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: GhoomoTextStyles.fontFamily,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: GhoomoColors.accent,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            'The world is big. Let Ghoomo make it accessible with personalized AI itineraries.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: GhoomoTextStyles.fontFamily,
                              fontSize: 18,
                              color: GhoomoColors.accent.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Get Started button
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GhoomoColors.accent,
                                foregroundColor: GhoomoColors.primary,
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(GhoomoRadius.full),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontFamily: GhoomoTextStyles.fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login link
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Already have an account? Log in',
                              style: TextStyle(
                                fontFamily: GhoomoTextStyles.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: GhoomoColors.accent.withOpacity(0.8),
                                decoration: TextDecoration.underline,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
