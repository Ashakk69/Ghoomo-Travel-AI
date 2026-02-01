import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: icon != null ? 16 : 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? GhoomoColors.primary : GhoomoColors.surfaceDark,
          borderRadius: BorderRadius.circular(GhoomoRadius.full),
          border: Border.all(
            color:
                isActive ? GhoomoColors.primary : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color:
                    isActive ? GhoomoColors.accent : GhoomoColors.textPrimary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: GhoomoTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color:
                    isActive ? GhoomoColors.accent : GhoomoColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
