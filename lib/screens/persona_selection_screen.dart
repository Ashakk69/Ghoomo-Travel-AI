import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_persona.dart';
import '../models/destination.dart';
import '../widgets/persona_card.dart';
import '../utils/responsive_helper.dart';
import 'planning_screen.dart';

class PersonaSelectionScreen extends StatefulWidget {
  final Destination destination;

  const PersonaSelectionScreen({super.key, required this.destination});

  @override
  State<PersonaSelectionScreen> createState() => _PersonaSelectionScreenState();
}

class _PersonaSelectionScreenState extends State<PersonaSelectionScreen>
    with SingleTickerProviderStateMixin {
  UserPersona? _selectedPersona;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    if (_selectedPersona != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlanningScreen(
            destination: widget.destination,
            persona: _selectedPersona!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: ResponsiveHelper.responsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Choose Your Travel Style',
                    style: GoogleFonts.outfit(
                      fontSize: ResponsiveHelper.responsiveFontSize(
                        context,
                        mobile: 28,
                        tablet: 32,
                        desktop: 36,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a persona to personalize your ${widget.destination.name} experience',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Persona list
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding:
                      ResponsiveHelper.responsiveHorizontalPadding(context),
                  physics: const BouncingScrollPhysics(),
                  itemCount: UserPersona.values.length,
                  itemBuilder: (context, index) {
                    final persona = UserPersona.values[index];
                    return PersonaCard(
                      persona: persona,
                      isSelected: _selectedPersona == persona,
                      onTap: () {
                        setState(() {
                          _selectedPersona = persona;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            // Continue button
            Padding(
              padding: ResponsiveHelper.responsivePadding(context),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedPersona != null ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPersona?.color ?? Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: _selectedPersona != null ? 10 : 0,
                    shadowColor: _selectedPersona?.color.withValues(alpha: 0.5),
                  ),
                  child: Text(
                    'Continue to Planning',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
