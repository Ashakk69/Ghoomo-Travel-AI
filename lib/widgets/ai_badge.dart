import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';

enum AIBadgeType {
  tip,
  alert,
  foodie,
  notification,
}

class AIBadge extends StatelessWidget {
  final AIBadgeType type;
  final String message;

  const AIBadge({
    super.key,
    required this.type,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(GhoomoRadius.medium),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Icon(
              _getIcon(),
              color: _getColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_getLabel()}: ',
                    style: const TextStyle(
                      fontFamily: GhoomoTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: message,
                    style: TextStyle(
                      fontFamily: GhoomoTextStyles.fontFamily,
                      fontSize: 14,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case AIBadgeType.tip:
        return Icons.auto_awesome;
      case AIBadgeType.alert:
        return Icons.notifications_active;
      case AIBadgeType.foodie:
        return Icons.restaurant;
      case AIBadgeType.notification:
        return Icons.info_outline;
    }
  }

  Color _getColor() {
    switch (type) {
      case AIBadgeType.tip:
        return GhoomoColors.primary;
      case AIBadgeType.alert:
        return GhoomoColors.primary;
      case AIBadgeType.foodie:
        return GhoomoColors.primary;
      case AIBadgeType.notification:
        return GhoomoColors.info;
    }
  }

  String _getLabel() {
    switch (type) {
      case AIBadgeType.tip:
        return 'AI Tip';
      case AIBadgeType.alert:
        return 'Alert';
      case AIBadgeType.foodie:
        return 'Foodie Tip';
      case AIBadgeType.notification:
        return 'Notification';
    }
  }
}
