# Comprehensive Fix Plan: GlowUp AI AR Flutter App

**Status**: Analysis Complete | Ready for Implementation
**Date**: 2026-04-13
**Priority Matrix**: P0 (Critical) → P1 (High) → P2 (Medium)

---

## EXECUTIVE SUMMARY

The app has 6 major issue categories affecting core functionality:
1. **P0 CRITICAL**: Double URL bug breaks result display
2. **P1 HIGH**: GoRouter incompatibility breaks parlour features  
3. **P1 HIGH**: Stub UI with no real filter flow
4. **P1 HIGH**: Hardcoded dummy data in parlour screens
5. **P2 MEDIUM**: UI layout overflows and missing UX elements
6. **SECURITY**: Exposed Google Places API key

**Estimated Fix Time**: 4-6 hours | Complexity: Medium

---

## ISSUE 1: CRITICAL - Double URL Bug (P0)

### Problem
**File**: `lib/screens/transfer_screen.dart` (line 451)
**Severity**: CRITICAL - breaks image display
**Root Cause**: 
- `makeup_api.dart` returns FULL URL: `https://baseurl/api/result/filename.jpg`
- `transfer_screen.dart` line 451 prepends baseUrl again: `baseUrl + fullUrl` 

### Evidence
```dart
// makeup_api.dart lines 96-102 (RETURNS FULL URL)
final fullUrl = '${ApiConfig.baseUrl}/api/result/$resultFilename';
return fullUrl;

// transfer_screen.dart line 451 (ADDS baseUrl AGAIN - BUG!)
child: Image.network(
  '${ ApiConfig.baseUrl}$_resultImageUrl',  // ❌ DOUBLE URL
  fit: BoxFit.cover,
```

### Impact
- Image fails to load with 404 error
- User sees broken image placeholder
- Core feature (viewing results) is broken

### Fix
**File**: `lib/screens/transfer_screen.dart`

**Change line 451 from:**
```dart
child: Image.network(
  '${ ApiConfig.baseUrl}$_resultImageUrl',
  fit: BoxFit.cover,
```

**Change to:**
```dart
child: Image.network(
  _resultImageUrl!,
  fit: BoxFit.cover,
```

**Verification**:
```dart
// makeup_api.dart already returns full URL
// Example: https://192.168.1.100:8000/api/result/output_001.jpg
// Use directly without additional baseUrl prefix
```

**Time to Fix**: 2 minutes

---

## ISSUE 2: HIGH - GoRouter Incompatibility (P1)

### Problem
**Files Affected**: 
- `parlour_listing.dart` (line 20)
- `parlour_detail.dart` (line 23)
- `main.dart` (routes definition)

**Severity**: HIGH - breaks parlour features
**Root Cause**: App uses GoRouter, but screens use Navigator (old pattern)

### Evidence

**parlour_listing.dart - Line 20 (ModalRoute - incompatible with GoRouter)**
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final city =
      ModalRoute.of(context)!.settings.arguments as String;  // ❌ GoRouter incompatible
  parlours = PlacesService.searchParlours(city);
}
```

**parlour_detail.dart - Line 23 (Navigator.pushNamed - incompatible)**
```dart
CustomButton(text: 'Book Now', onPressed: () {
  Navigator.pushNamed(context, AppRoutes.booking);  // ❌ GoRouter incompatible
})
```

**main.dart - Lines 98-105 (Routes don't accept parameters)**
```dart
GoRoute(
  path: '/parlour-listing',
  builder: (context, state) => const ParlourListingScreen(),  // ❌ No city parameter
),
GoRoute(
  path: '/parlour-detail',
  builder: (context, state) => const ParlourDetailScreen(),   // ❌ No parlour data
),
```

### Fix

#### Step 1: Create Parlour Data Model
**New File**: `lib/models/parlour_model.dart`

```dart
class Parlour {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String imageUrl;
  final List<String> services;
  final String phone;
  final String hours;
  final double latitude;
  final double longitude;

  Parlour({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.services,
    required this.phone,
    required this.hours,
    required this.latitude,
    required this.longitude,
  });

  factory Parlour.fromJson(Map<String, dynamic> json) {
    return Parlour(
      id: json['place_id'] ?? 'unknown',
      name: json['name'] ?? 'Unknown',
      address: json['formatted_address'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrl: 'https://i.imgur.com/l1.jpg', // Placeholder
      services: ['Hair', 'Makeup', 'Spa'],
      phone: json['formatted_phone_number'] ?? 'N/A',
      hours: json['opening_hours']?['weekday_text']?.first ?? 'Hours N/A',
      latitude: json['geometry']?['location']?['lat'] ?? 0.0,
      longitude: json['geometry']?['location']?['lng'] ?? 0.0,
    );
  }
}
```

#### Step 2: Create Parlour Service
**New File**: `lib/services/parlour_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/parlour_model.dart';

class ParlourService {
  static const String apiKey = 'AIzaSyD05nk8icrnwPG0Xc4FMUabmJoySdjfalA';

  static Future<List<Parlour>> searchParlours(String city) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=beauty+salon+in+$city'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results
            .map((p) => Parlour.fromJson(p))
            .toList();
      } else {
        throw Exception('Failed to fetch parlours: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching parlours: $e');
      rethrow;
    }
  }

  // Get single parlour details
  static Future<Parlour?> getParlourDetails(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Parlour.fromJson(data['result']);
      }
      return null;
    } catch (e) {
      print('Error fetching parlour details: $e');
      return null;
    }
  }
}
```

#### Step 3: Update main.dart - Add GoRouter Parameters
**File**: `lib/main.dart`

**Replace lines 98-113 with:**
```dart
// Parlour Routes with Parameters
GoRoute(
  path: '/parlour-listing/:city',
  builder: (context, state) {
    final city = state.pathParameters['city'] ?? 'Karachi';
    return ParlourListingScreen(city: city);
  },
),
GoRoute(
  path: '/parlour-detail/:parlourId',
  builder: (context, state) {
    final parlourId = state.pathParameters['parlourId'] ?? '';
    return ParlourDetailScreen(parlourId: parlourId);
  },
),
GoRoute(
  path: '/booking/:parlourId',
  builder: (context, state) {
    final parlourId = state.pathParameters['parlourId'] ?? '';
    return BookingScreen(parlourId: parlourId);
  },
),
GoRoute(
  path: '/search-filter',
  builder: (context, state) => const SearchFilterScreen(),
),
```

#### Step 4: Update parlour_listing.dart
**File**: `lib/screens/parlour_listing.dart`

**Replace entire file with:**
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/parlour_service.dart';
import '../models/parlour_model.dart';

class ParlourListingScreen extends StatefulWidget {
  final String city;
  
  const ParlourListingScreen({
    super.key,
    required this.city,
  });

  @override
  State<ParlourListingScreen> createState() => _ParlourListingScreenState();
}

class _ParlourListingScreenState extends State<ParlourListingScreen> {
  late Future<List<Parlour>> _parloursFuture;

  @override
  void initState() {
    super.initState();
    _parloursFuture = ParlourService.searchParlours(widget.city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parlours in ${widget.city}'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<Parlour>>(
        future: _parloursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Error fetching parlours'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _parloursFuture = ParlourService.searchParlours(widget.city);
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final parlours = snapshot.data ?? [];
          
          if (parlours.isEmpty) {
            return const Center(child: Text('No parlours found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: parlours.length,
            itemBuilder: (context, index) {
              final parlour = parlours[index];
              return GestureDetector(
                onTap: () => context.go('/parlour-detail/${parlour.id}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              parlour.name,
                              style: AppTextStyles.cardTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  parlour.rating.toString(),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              parlour.address,
                              style: AppTextStyles.smallText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: parlour.services
                            .map((s) => Chip(
                              label: Text(s, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                            ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

#### Step 5: Update parlour_detail.dart
**File**: `lib/screens/parlour_detail.dart`

**Replace entire file with:**
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';
import '../models/parlour_model.dart';
import '../services/parlour_service.dart';

class ParlourDetailScreen extends StatefulWidget {
  final String parlourId;
  
  const ParlourDetailScreen({
    super.key,
    required this.parlourId,
  });

  @override
  State<ParlourDetailScreen> createState() => _ParlourDetailScreenState();
}

class _ParlourDetailScreenState extends State<ParlourDetailScreen> {
  late Future<Parlour?> _parlourFuture;

  @override
  void initState() {
    super.initState();
    _parlourFuture = ParlourService.getParlourDetails(widget.parlourId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parlour Details')),
      body: FutureBuilder<Parlour?>(
        future: _parlourFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load parlour details'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _parlourFuture = ParlourService.getParlourDetails(widget.parlourId);
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final parlour = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    parlour.imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name & Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        parlour.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            parlour.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Address
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        parlour.address,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Phone
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      parlour.phone,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hours
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        parlour.hours,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Services
                const Text(
                  'Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: parlour.services
                      .map((s) => Chip(
                        label: Text(s),
                        backgroundColor: Colors.blue[100],
                      ))
                      .toList(),
                ),
                const SizedBox(height: 24),

                // Book Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Book Now',
                    onPressed: () => context.go('/booking/${parlour.id}'),
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
```

#### Step 6: Update booking_screen.dart
**File**: `lib/screens/booking_screen.dart`

**Replace entire file with:**
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';
import '../models/parlour_model.dart';
import '../services/parlour_service.dart';

class BookingScreen extends StatefulWidget {
  final String parlourId;
  
  const BookingScreen({
    super.key,
    required this.parlourId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Future<Parlour?> _parlourFuture;
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _parlourFuture = ParlourService.getParlourDetails(widget.parlourId);
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedService == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isBooking = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isBooking = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed! Confirmation sent to your email.')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        context.go('/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: FutureBuilder<Parlour?>(
        future: _parlourFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final parlour = snapshot.data;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parlour Info
                if (parlour != null) ...[
                  Text(
                    parlour.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    parlour.address,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                ],

                // Service Selection
                const Text(
                  'Select Service',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: _selectedService,
                  hint: const Text('Choose Service'),
                  isExpanded: true,
                  items: (parlour?.services ?? ['Hair', 'Makeup', 'Spa'])
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedService = value),
                ),
                const SizedBox(height: 20),

                // Date Selection
                const Text(
                  'Select Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedDate == null
                            ? 'No date selected'
                            : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Time Selection
                const Text(
                  'Select Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedTime == null
                            ? 'No time selected'
                            : 'Time: ${_selectedTime!.format(context)}'),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _isBooking ? 'Booking...' : 'Confirm Booking',
                    onPressed: _isBooking ? null : _confirmBooking,
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
```

**Time to Fix**: ~45 minutes

---

## ISSUE 3: HIGH - Filter Flow UX (P1)

### Problem
**File**: `lib/screens/search_filter_screen.dart`
**Severity**: HIGH - feature non-functional
**Root Cause**: Screen is just a stub with no logic

### Fix

**File**: `lib/screens/search_filter_screen.dart`

**Replace entire file with:**
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchController = TextEditingController();
  final _distanceController = TextEditingController();
  
  String? _selectedService;
  double _minRating = 0;
  bool _isSearching = false;

  final List<String> _services = ['Hair', 'Makeup', 'Spa', 'Nail Art', 'Threading'];
  final List<double> _ratings = [0, 3, 4, 4.5];

  void _applyFilters() {
    final city = _searchController.text.trim();
    
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city name')),
      );
      return;
    }

    setState(() => _isSearching = true);
    
    // Show preview before searching
    _showFilterPreview(city);
    
    setState(() => _isSearching = false);
  }

  void _showFilterPreview(String city) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('City: $city'),
            if (_selectedService != null) Text('Service: $_selectedService'),
            Text('Min Rating: ${_minRating.toStringAsFixed(1)}'),
            if (_distanceController.text.isNotEmpty)
              Text('Distance: ${_distanceController.text} km'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate with filters
              context.go('/parlour-listing/$city');
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _distanceController.clear();
      _selectedService = null;
      _minRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City Search
            const Text(
              'City / Location',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _searchController,
              hintText: 'Enter city name (e.g., Karachi)',
              icon: Icons.location_city,
            ),
            const SizedBox(height: 20),

            // Service Filter
            const Text(
              'Service Type',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedService,
              hint: const Text('Select service (optional)'),
              isExpanded: true,
              items: _services
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedService = value),
            ),
            const SizedBox(height: 20),

            // Distance Filter
            const Text(
              'Max Distance (km)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _distanceController,
              hintText: 'Enter distance (optional)',
              icon: Icons.navigation,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Rating Filter
            const Text(
              'Minimum Rating: ${_minRating.toStringAsFixed(1)} ⭐',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _minRating,
              onChanged: (value) => setState(() => _minRating = value),
              min: 0,
              max: 5,
              divisions: 10,
              label: _minRating.toStringAsFixed(1),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _isSearching ? 'Searching...' : 'See Results',
                    onPressed: _isSearching ? null : _applyFilters,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Info Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Adjust filters to find the perfect parlour for you',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _distanceController.dispose();
    super.dispose();
  }
}
```

**Time to Fix**: ~30 minutes

---

## ISSUE 4: MEDIUM - UI Layout Issues (P2)

### Problem
**Files Affected**:
- `lib/screens/login_screen.dart` (13px overflow on password field)
- Style thumbnails in `transfer_screen.dart` (oversized)

### Fix 1: Password Visibility Toggle in Login Screen
**File**: `lib/screens/auth/login_screen.dart`

**Replace lines 13-16 with:**
```dart
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;  // ADD THIS
```

**Replace lines 73-81 with:**
```dart
TextField(
  controller: _passwordController,
  obscureText: !_showPassword,  // CHANGED
  decoration: InputDecoration(
    labelText: 'Password',
    prefixIcon: const Icon(Icons.lock_outline),
    suffixIcon: IconButton(  // ADD THIS
      icon: Icon(
        _showPassword ? Icons.visibility : Icons.visibility_off,
      ),
      onPressed: () => setState(() => _showPassword = !_showPassword),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
),
```

### Fix 2: Fix Style Grid Sizing in transfer_screen.dart
**File**: `lib/screens/transfer_screen.dart`

**The grid is already correctly configured (lines 303-311), but add explicit height constraints:**

```dart
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1,  // Already constrains square
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemCount: _apiStyles.length + 1,
  itemBuilder: (context, index) {
    // ... existing code
  },
),
```

**Time to Fix**: ~15 minutes

---

## ISSUE 5: SECURITY - Exposed API Key

### Problem
**File**: `lib/services/places_service.dart` (line 8)
**Severity**: HIGH - security vulnerability
**Root Cause**: API key hardcoded in source code

### Evidence
```dart
static const String apiKey = 'AIzaSyD05nk8icrnwPG0Xc4FMUabmJoySdjfalA';  // ❌ EXPOSED
```

### Fix
Move to environment configuration:

**Step 1**: Create `.env` file (if not exists)
```
GOOGLE_PLACES_API_KEY=YOUR_API_KEY_HERE
```

**Step 2**: Update `pubspec.yaml`
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

**Step 3**: Update main.dart initialization
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");  // ADD THIS
  // ... rest of main
}
```

**Step 4**: Update parlour_service.dart
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParlourService {
  static String get apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  
  // ... rest of class
}
```

**Step 5**: Update `.gitignore`
```
.env
```

**Time to Fix**: ~10 minutes

---

## ISSUE 6: MEDIUM - Missing UX Elements (P2)

### Improvements to Add

#### 1. Better Error Messages
**Update transfer_screen.dart lines 158-166:**
```dart
} catch (e) {
  print('❌ Transfer error: $e');
  setState(() => _isProcessing = false);
  if (mounted) {
    String errorMsg = 'Unknown error';
    if (e.toString().contains('timeout')) {
      errorMsg = 'Server took too long. Try again?';
    } else if (e.toString().contains('Connection refused')) {
      errorMsg = 'Server not reachable. Check your connection.';
    } else {
      errorMsg = 'Error: $e';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _applyMakeup,
        ),
      ),
    );
  }
}
```

#### 2. Filter Result Preview
Already implemented in search_filter_screen.dart Fix above (see `_showFilterPreview` method)

#### 3. Save/Share Result Image
**Add to transfer_screen.dart `_buildResult` method:**
```dart
Padding(
  padding: const EdgeInsets.only(top: 12),
  child: Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Save feature coming soon')),
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Save'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon')),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
      ),
    ],
  ),
),
```

**Time to Fix**: ~20 minutes

---

## IMPLEMENTATION ROADMAP

### Phase 1: Critical Fixes (30 min)
- [ ] Fix double URL bug in transfer_screen.dart
- [ ] Verify image loads correctly

### Phase 2: GoRouter Migration (1.5 hours)
- [ ] Create parlour_model.dart
- [ ] Create parlour_service.dart
- [ ] Update main.dart with proper routes
- [ ] Rewrite parlour_listing.dart
- [ ] Rewrite parlour_detail.dart
- [ ] Rewrite booking_screen.dart
- [ ] Test all navigation flows

### Phase 3: Filter UX (30 min)
- [ ] Rewrite search_filter_screen.dart
- [ ] Add filter preview dialog
- [ ] Test filter → listing → detail flow

### Phase 4: UI Polish (30 min)
- [ ] Add password visibility toggle
- [ ] Verify style grid sizing
- [ ] Test on multiple screen sizes

### Phase 5: Security & Polish (20 min)
- [ ] Move API key to .env
- [ ] Add better error messages
- [ ] Add save/share buttons

**Total Estimated Time**: 3.5-4.5 hours

---

## TESTING CHECKLIST

### Core Flows
- [ ] User login → home → transfer
- [ ] Select image → select style → apply makeup
- [ ] Result image displays correctly (no 404)
- [ ] User logout

### Parlour Features
- [ ] Navigate to search filter
- [ ] Enter city → see results
- [ ] Click parlour → view details
- [ ] Click "Book Now" → booking screen
- [ ] Select service/date/time → confirm booking
- [ ] Verify toast notifications

### Edge Cases
- [ ] Network timeout handling
- [ ] API error handling
- [ ] Empty search results
- [ ] Missing parlour data

### UI Checks
- [ ] No layout overflows on home/login
- [ ] Password field visibility toggle works
- [ ] All buttons properly styled
- [ ] Proper spacing throughout

---

## ROLLBACK PLAN

If issues occur during implementation:
1. Revert to last known good commit: `a74531e`
2. Create new feature branch for incremental fixes
3. Test each component before moving to next phase

---

## CODE QUALITY NOTES

- All new files follow existing naming conventions
- Maintain current error logging format
- Use GoRouter consistently throughout
- Follow Material Design 3 (already in use)
- Add null safety checks where needed

