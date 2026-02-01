import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../utils/theme_constants.dart';
import '../services/preferences_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/feed_item.dart';
import '../widgets/filter_chip.dart';
import '../widgets/ai_badge.dart';
import 'dashboard_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'persona_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PreferencesService _prefsService = PreferencesService();
  int _currentNavIndex = 0;
  String _selectedFilter = 'Trending';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'Trending',
    'Solo',
    'Luxury',
    'Nature',
    'Budget',
    'Culture',
    'Romance',
    'Adventure',
  ];

  final List<Destination> _allDestinations = Destination.mockDestinations;

  final Map<String, String> _aiTips = {
    'Paris':
        'Use our optimized route to avoid the crowds at the Eiffel Tower during peak hours (10 AM - 2 PM). The Trocadéro viewpoint is empty at sunrise.',
    'Tokyo':
        'The JR Pass booking window opens 3 months in advance. Tap "Plan This" to set a reminder for your travel dates.',
    'Bali':
        'Here are 3 hidden beach clubs in Seminyak that welcome solo travelers and don\'t require a reservation.',
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final filter = await _prefsService.getSelectedFilter();
    if (mounted) {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  List<Destination> get _filteredDestinations {
    var destinations = _allDestinations;

    // Apply search filter
    if (_isSearching && _searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      destinations = destinations
          .where((d) =>
              d.name.toLowerCase().contains(query) ||
              d.country.toLowerCase().contains(query))
          .toList();
    }

    // Apply category filter
    if (_selectedFilter != 'Trending') {
      destinations = destinations.where((d) {
        if (_selectedFilter == 'Budget') {
          return d.estimatedCost < 1000;
        } else if (_selectedFilter == 'Luxury') {
          return d.estimatedCost > 1500;
        } else {
          return d.category == _selectedFilter;
        }
      }).toList();
    }

    return destinations;
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  Future<void> _onFilterTap(String filter) async {
    setState(() {
      _selectedFilter = filter;
    });
    await _prefsService.saveSelectedFilter(filter);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  void _navigateToPlanning(Destination destination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonaSelectionScreen(destination: destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeTab(),
          const SavedScreen(),
          const DashboardScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _currentNavIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                if (_allDestinations.isNotEmpty) {
                  _navigateToPlanning(_allDestinations.first);
                }
              },
              backgroundColor: GhoomoColors.primary,
              child: const Icon(
                Icons.add,
                color: GhoomoColors.accent,
                size: 32,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Search bar (if searching)
          if (_isSearching) _buildSearchBar(),

          // Filter Chips
          _buildFilterChips(),

          // Feed
          Expanded(
            child: _filteredDestinations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 100),
                    itemCount: _filteredDestinations.length,
                    itemBuilder: (context, index) {
                      final destination = _filteredDestinations[index];
                      return FeedItem(
                        destination: destination,
                        onPlanThis: () => _navigateToPlanning(destination),
                        aiTip: _aiTips[destination.name] ??
                            'Discover the best time to visit ${destination.name} with our AI-powered insights.',
                        tipType: index % 3 == 0
                            ? AIBadgeType.tip
                            : index % 3 == 1
                                ? AIBadgeType.alert
                                : AIBadgeType.foodie,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore',
                  style: GhoomoTextStyles.h1,
                ),
                Text(
                  'Find your dream destination',
                  style: GhoomoTextStyles.body.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        style: GhoomoTextStyles.body,
        decoration: InputDecoration(
          hintText: 'Search destinations...',
          hintStyle: GhoomoTextStyles.body.copyWith(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: GhoomoColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: _filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChipWidget(
              label: filter,
              isActive: _selectedFilter == filter,
              onTap: () => _onFilterTap(filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'No destinations found',
            style: GhoomoTextStyles.h2.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
