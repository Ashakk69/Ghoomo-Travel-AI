import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';
import '../services/preferences_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PreferencesService _prefsService = PreferencesService();
  Map<String, bool> _travelStyles = {};
  Map<String, bool> _aiSettings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final styles = await _prefsService.getTravelStyles();
    final settings = await _prefsService.getAISettings();

    if (mounted) {
      setState(() {
        _travelStyles = styles;
        _aiSettings = settings;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    final stylesSuccess = await _prefsService.saveTravelStyles(_travelStyles);
    final settingsSuccess = await _prefsService.saveAISettings(_aiSettings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stylesSuccess && settingsSuccess
                ? 'Preferences saved!'
                : 'Error saving preferences',
          ),
          backgroundColor: stylesSuccess && settingsSuccess
              ? GhoomoColors.success
              : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: GhoomoColors.backgroundDark,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: GhoomoColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  // Profile header
                  _buildProfileHeader(),

                  // Travel Style section
                  _buildTravelStyleSection(),

                  // AI Personalization section
                  _buildAIPersonalizationSection(),

                  // Save button
                  _buildSaveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: GhoomoTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: GhoomoColors.primary,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GhoomoColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: GhoomoColors.surfaceDark,
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: GhoomoColors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: GhoomoColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: GhoomoColors.backgroundDark,
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: GhoomoColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Travel Explorer',
                style: GhoomoTextStyles.h2,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.verified,
                color: GhoomoColors.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '@explorer • New York, NY',
            style: GhoomoTextStyles.bodySmall.copyWith(
              color: GhoomoColors.textSecondary,
            ),
          ),

          // Stats
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('12', 'Countries'),
              _buildStat('47', 'Trips'),
              _buildStat('4.8', 'Rating'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GhoomoTextStyles.h2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: GhoomoTextStyles.caption.copyWith(
            color: GhoomoColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTravelStyleSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travel Style',
            style: GhoomoTextStyles.h3,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _travelStyles.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _travelStyles[entry.key] = !entry.value;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: entry.value
                        ? GhoomoColors.primary
                        : GhoomoColors.surfaceDark,
                    borderRadius: BorderRadius.circular(GhoomoRadius.full),
                    boxShadow: entry.value
                        ? [
                            BoxShadow(
                              color:
                                  GhoomoColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStyleIcon(entry.key),
                        size: 20,
                        color: entry.value ? GhoomoColors.accent : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontFamily: GhoomoTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight:
                              entry.value ? FontWeight.bold : FontWeight.w500,
                          color:
                              entry.value ? GhoomoColors.accent : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPersonalizationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'AI Personalization',
                style: GhoomoTextStyles.h3,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GhoomoColors.primary.withValues(alpha: 0.8),
                      Colors.orange.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'BETA',
                  style: TextStyle(
                    fontFamily: GhoomoTextStyles.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: GhoomoColors.accent,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._aiSettings.entries.map((entry) {
            return _buildAIToggle(
              entry.key,
              _getAIDescription(entry.key),
              entry.value,
              _getAIIcon(entry.key),
              _getAIColor(entry.key),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAIToggle(
    String title,
    String description,
    bool value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhoomoColors.surfaceDark,
        borderRadius: BorderRadius.circular(GhoomoRadius.medium),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(GhoomoRadius.medium),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GhoomoTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: GhoomoTextStyles.caption.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                _aiSettings[title] = newValue;
              });
            },
            activeThumbColor: GhoomoColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _savePreferences,
          style: ElevatedButton.styleFrom(
            backgroundColor: GhoomoColors.primary,
            foregroundColor: GhoomoColors.accent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GhoomoRadius.full),
            ),
          ),
          child: Text(
            'Save Preferences',
            style: GhoomoTextStyles.button.copyWith(
              color: GhoomoColors.accent,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStyleIcon(String style) {
    switch (style) {
      case 'Backpacker':
        return Icons.backpack;
      case 'Luxury':
        return Icons.diamond;
      case 'Nightlife':
        return Icons.nightlife;
      case 'Nature':
        return Icons.forest;
      case 'History':
        return Icons.museum;
      case 'Relaxation':
        return Icons.spa;
      default:
        return Icons.star;
    }
  }

  String _getAIDescription(String setting) {
    switch (setting) {
      case 'Smart Budgeting':
        return 'Find best deals automatically';
      case 'Hidden Gems':
        return 'Prioritize off-path spots';
      case 'Eco Routing':
        return 'Lowest carbon footprint';
      default:
        return '';
    }
  }

  IconData _getAIIcon(String setting) {
    switch (setting) {
      case 'Smart Budgeting':
        return Icons.savings;
      case 'Hidden Gems':
        return Icons.explore;
      case 'Eco Routing':
        return Icons.eco;
      default:
        return Icons.auto_awesome;
    }
  }

  Color _getAIColor(String setting) {
    switch (setting) {
      case 'Smart Budgeting':
        return GhoomoColors.primary;
      case 'Hidden Gems':
        return Colors.blue;
      case 'Eco Routing':
        return Colors.green;
      default:
        return GhoomoColors.primary;
    }
  }
}
