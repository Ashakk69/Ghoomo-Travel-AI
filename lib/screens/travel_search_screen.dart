import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/travel_preferences.dart';
import '../models/currency.dart';
import 'travel_results_screen.dart';

/// Comprehensive travel search screen to collect user preferences
class TravelSearchScreen extends StatefulWidget {
  final String? initialDestination;
  final Currency currency;

  const TravelSearchScreen({
    super.key,
    this.initialDestination,
    required this.currency,
  });

  @override
  State<TravelSearchScreen> createState() => _TravelSearchScreenState();
}

class _TravelSearchScreenState extends State<TravelSearchScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _originController = TextEditingController(text: 'Delhi');
  final _destinationController = TextEditingController();

  // Dates
  DateTime _departureDate = DateTime.now().add(const Duration(days: 7));
  DateTime? _returnDate;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  // Times
  String? _departureTime;
  String? _returnTime;

  // Transportation
  String _transportMode = 'all';
  int _passengers = 1;
  String _cabinClass = 'ECONOMY';

  // Accommodation
  int _guests = 2;
  int _rooms = 1;

  // Budget
  double? _minBudget;
  double? _maxBudget;

  // Filters
  int? _maxStops;
  double? _minHotelRating;
  String? _hotelType;

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null) {
      _destinationController.text = widget.initialDestination!;
    }
    // Auto-set check-in/out based on departure/return
    _checkInDate = _departureDate;
    _checkOutDate = _returnDate ?? _departureDate.add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture
          ? _departureDate
          : (_returnDate ?? _departureDate.add(const Duration(days: 3))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              surface: const Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          _checkInDate = picked;
          // Adjust return date if it's before departure
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = picked.add(const Duration(days: 3));
            _checkOutDate = _returnDate;
          }
        } else {
          _returnDate = picked;
          _checkOutDate = picked;
        }
      });
    }
  }

  void _searchTravel() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final preferences = TravelPreferences(
      origin: _originController.text.trim(),
      destination: _destinationController.text.trim(),
      departureDate: _departureDate,
      returnDate: _returnDate,
      departureTime: _departureTime,
      returnTime: _returnTime,
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      guests: _guests,
      rooms: _rooms,
      transportMode: _transportMode,
      passengers: _passengers,
      cabinClass: _cabinClass,
      minBudget: _minBudget,
      maxBudget: _maxBudget,
      maxStops: _maxStops,
      minHotelRating: _minHotelRating,
      hotelType: _hotelType,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TravelResultsScreen(
          preferences: preferences,
          currency: widget.currency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          'Plan Your Trip',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Text(
              'Where would you like to go?',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Origin & Destination
            _buildSectionCard(
              icon: Icons.location_on,
              title: 'Locations',
              children: [
                _buildTextField(
                  controller: _originController,
                  label: 'From',
                  icon: Icons.flight_takeoff,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _destinationController,
                  label: 'To',
                  icon: Icons.flight_land,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Dates
            _buildSectionCard(
              icon: Icons.calendar_today,
              title: 'Travel Dates',
              children: [
                _buildDateSelector(
                  label: 'Departure',
                  date: _departureDate,
                  onTap: () => _selectDate(context, true),
                ),
                const SizedBox(height: 12),
                _buildDateSelector(
                  label: 'Return (Optional)',
                  date: _returnDate,
                  onTap: () => _selectDate(context, false),
                  isOptional: true,
                  onClear: () => setState(() {
                    _returnDate = null;
                    _checkOutDate = _checkInDate?.add(const Duration(days: 3));
                  }),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Time Preferences
            _buildSectionCard(
              icon: Icons.access_time,
              title: 'Preferred Times',
              children: [
                _buildTimeSelector(
                  label: 'Departure Time',
                  value: _departureTime,
                  onChanged: (value) => setState(() => _departureTime = value),
                ),
                if (_returnDate != null) ...[
                  const SizedBox(height: 12),
                  _buildTimeSelector(
                    label: 'Return Time',
                    value: _returnTime,
                    onChanged: (value) => setState(() => _returnTime = value),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),

            // Transportation Mode
            _buildSectionCard(
              icon: Icons.directions,
              title: 'Transportation',
              children: [
                _buildTransportModeSelector(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCounterField(
                        label: 'Passengers',
                        value: _passengers,
                        onChanged: (value) =>
                            setState(() => _passengers = value),
                      ),
                    ),
                    if (_transportMode == 'flight' ||
                        _transportMode == 'all') ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Class',
                          value: _cabinClass,
                          items: const [
                            'ECONOMY',
                            'PREMIUM_ECONOMY',
                            'BUSINESS',
                            'FIRST'
                          ],
                          displayNames: const [
                            'Economy',
                            'Premium',
                            'Business',
                            'First'
                          ],
                          onChanged: (value) =>
                              setState(() => _cabinClass = value!),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Accommodation
            _buildSectionCard(
              icon: Icons.hotel,
              title: 'Accommodation',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCounterField(
                        label: 'Guests',
                        value: _guests,
                        onChanged: (value) => setState(() => _guests = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCounterField(
                        label: 'Rooms',
                        value: _rooms,
                        onChanged: (value) => setState(() => _rooms = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Hotel Type (Optional)',
                  value: _hotelType,
                  items: const [
                    null,
                    'BUDGET',
                    'MID_RANGE',
                    'LUXURY',
                    'BOUTIQUE'
                  ],
                  displayNames: const [
                    'Any',
                    'Budget',
                    'Mid-Range',
                    'Luxury',
                    'Boutique'
                  ],
                  onChanged: (value) => setState(() => _hotelType = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Budget
            _buildSectionCard(
              icon: Icons.attach_money,
              title: 'Budget (Optional)',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Min Budget',
                        icon: Icons.money_off,
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _minBudget = double.tryParse(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Max Budget',
                        icon: Icons.money,
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _maxBudget = double.tryParse(value),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Search Button
            ElevatedButton(
              onPressed: _searchTravel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Search Travel Options',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2A2A),
            const Color(0xFF1E1E1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool isOptional = false,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('MMM dd, yyyy').format(date)
                        : 'Select date',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (isOptional && date != null && onClear != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildTimeChip('Morning', 'morning', value, onChanged),
            _buildTimeChip('Afternoon', 'afternoon', value, onChanged),
            _buildTimeChip('Evening', 'evening', value, onChanged),
            _buildTimeChip('Night', 'night', value, onChanged),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeChip(String label, String chipValue, String? currentValue,
      void Function(String?) onChanged) {
    final isSelected = currentValue == chipValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onChanged(selected ? chipValue : null),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: GoogleFonts.outfit(
        color: isSelected ? Colors.white : Colors.white70,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).primaryColor
            : Colors.white.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildTransportModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildModeChip('All', 'all', Icons.explore),
            _buildModeChip('Flight', 'flight', Icons.flight),
            _buildModeChip('Train', 'train', Icons.train),
            _buildModeChip('Bus', 'bus', Icons.directions_bus),
            _buildModeChip('Car', 'car_rental', Icons.directions_car),
          ],
        ),
      ],
    );
  }

  Widget _buildModeChip(String label, String value, IconData icon) {
    final isSelected = _transportMode == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16, color: isSelected ? Colors.white : Colors.white70),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => setState(() => _transportMode = value),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: GoogleFonts.outfit(
        color: isSelected ? Colors.white : Colors.white70,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).primaryColor
            : Colors.white.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildCounterField({
    required String label,
    required int value,
    required void Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Theme.of(context).primaryColor,
                iconSize: 20,
              ),
              Text(
                value.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline),
                color: Theme.of(context).primaryColor,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required dynamic value,
    required List<dynamic> items,
    required List<String> displayNames,
    required void Function(dynamic) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2A2A2A),
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          items: List.generate(items.length, (index) {
            return DropdownMenuItem(
              value: items[index],
              child: Text(displayNames[index]),
            );
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
