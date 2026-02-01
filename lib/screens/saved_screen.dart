import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/preferences_service.dart';
import '../utils/theme_constants.dart';
import 'persona_selection_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final PreferencesService _prefsService = PreferencesService();
  Set<String> _savedDestinationIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedDestinations();
  }

  Future<void> _loadSavedDestinations() async {
    final saved = await _prefsService.getSavedDestinations();
    if (mounted) {
      setState(() {
        _savedDestinationIds = saved;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeSaved(String destinationId) async {
    await _prefsService.toggleSavedDestination(destinationId);
    await _loadSavedDestinations();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedDestinations = Destination.mockDestinations
        .where((d) => _savedDestinationIds.contains(d.id))
        .toList();

    return Scaffold(
      backgroundColor: GhoomoColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Saved',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: GhoomoColors.backgroundDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedDestinations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSavedDestinations,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: savedDestinations.length,
                    itemBuilder: (context, index) {
                      final destination = savedDestinations[index];
                      return _buildSavedCard(destination);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Destinations',
              style: GhoomoTextStyles.h2.copyWith(
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the bookmark icon on any destination to save it here',
              textAlign: TextAlign.center,
              style: GhoomoTextStyles.body.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard(Destination destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PersonaSelectionScreen(destination: destination),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GhoomoRadius.large),
          boxShadow: GhoomoShadows.medium,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(GhoomoRadius.large),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: Image.asset(
                  destination.imageAsset,
                  fit: BoxFit.cover,
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Remove button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removeSaved(destination.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      color: GhoomoColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        destination.name,
                        style: GhoomoTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              destination.country,
                              style: GhoomoTextStyles.caption.copyWith(
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
