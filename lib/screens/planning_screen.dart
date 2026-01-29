import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/destination.dart';
import '../models/user_persona.dart';
import '../models/currency.dart';
import '../widgets/currency_selector.dart';
import 'loading_screen.dart';

class PlanningScreen extends StatefulWidget {
  final Destination destination;
  final UserPersona persona;

  const PlanningScreen({
    super.key,
    required this.destination,
    required this.persona,
  });

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double _budget = 1500;
  int _days = 5;
  Currency _selectedCurrency = Currency.usd;
  final List<String> _interests = [
    'Food',
    'Nature',
    'Nightlife',
    'Culture',
    'Relax'
  ];
  final Set<String> _selectedInterests = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Hero)
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.55,
            child: Hero(
              tag: 'destination-${widget.destination.id}',
              child: Image.asset(
                widget.destination.imageAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // Draggable/Scrollable Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip to ${widget.destination.name}',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Persona chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.persona.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: widget.persona.color, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(widget.persona.icon,
                                  color: widget.persona.color, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                widget.persona.displayName,
                                style: GoogleFonts.outfit(
                                  color: widget.persona.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Customize your itinerary for the perfect experience.',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Currency Selector
                        Text(
                          'CURRENCY',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white38,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CurrencySelector(
                          selectedCurrency: _selectedCurrency,
                          onChanged: (currency) {
                            if (currency != null) {
                              setState(() => _selectedCurrency = currency);
                            }
                          },
                        ),
                        const SizedBox(height: 32),

                        // Duration Slider
                        _buildSectionTitle('Duration'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$_days Days',
                                style: GoogleFonts.outfit(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Expanded(
                                child: Slider(
                              value: _days.toDouble(),
                              min: 1,
                              max: 14,
                              divisions: 13,
                              label: '$_days Days',
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (val) =>
                                  setState(() => _days = val.toInt()),
                            )),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Budget Slider
                        _buildSectionTitle('Budget'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$$_budget.toInt()',
                                style: GoogleFonts.outfit(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Expanded(
                                child: Slider(
                              value: _budget,
                              min: 500,
                              max: 10000,
                              divisions: 95,
                              label: '\$${_budget.toInt()}',
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (val) => setState(() => _budget = val),
                            )),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Interests Chips
                        _buildSectionTitle('Interests'),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _interests.map((interest) {
                            final isSelected =
                                _selectedInterests.contains(interest);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSelected
                                      ? _selectedInterests.remove(interest)
                                      : _selectedInterests.add(interest);
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.white12,
                                  ),
                                ),
                                child: Text(
                                  interest,
                                  style: GoogleFonts.outfit(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 48),

                        // Generate Button area
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoadingScreen(
                                    destination: widget.destination,
                                    persona: widget.persona,
                                    currency: _selectedCurrency,
                                    budgetUSD: _budget,
                                    days: _days,
                                    interests: _selectedInterests,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 10,
                              shadowColor: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.5),
                            ),
                            child: Text(
                              'Generate Trip',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48), // Padding bottom
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.white38,
      ),
    );
  }
}
