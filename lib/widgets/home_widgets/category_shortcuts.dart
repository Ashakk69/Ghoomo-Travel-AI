import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryShortcuts extends StatelessWidget {
  final Function(String) onCategoryTap;

  const CategoryShortcuts({super.key, required this.onCategoryTap});

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Chill', 'icon': '😊', 'color': Color(0xFFEBC137)},
    {'name': 'Adventure', 'icon': '⛺', 'color': Color(0xFF4A90E2)},
    {'name': 'Budget', 'icon': '💵', 'color': Color(0xFF50C878)},
    {'name': 'Romantic', 'icon': '❤️', 'color': Color(0xFFFF6B6B)},
    {'name': 'Solo', 'icon': '🎒', 'color': Color(0xFF6C63FF)},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () => onCategoryTap(category['name']),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: category['color'],
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (category['color'] as Color).withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      category['icon'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'],
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
