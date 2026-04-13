import '../models/parlour_model.dart';

class ParloursRepository {
  static final List<Parlour> _mockParlours = [
    Parlour(
      id: 'p1',
      name: 'Beauty Hub',
      address: '123 Main St, Downtown',
      phone: '+92-300-1234567',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1552820728-8ac41f1ce891?w=500',
      description: 'Premium beauty and makeup services with expert stylists',
      services: [
        ParlourService(id: 's1', name: 'Bridal Makeup', price: 5000, durationMinutes: 90),
        ParlourService(id: 's2', name: 'Party Makeup', price: 3000, durationMinutes: 60),
        ParlourService(id: 's3', name: 'Hair Styling', price: 2000, durationMinutes: 45),
        ParlourService(id: 's4', name: 'Facial', price: 1500, durationMinutes: 30),
      ],
    ),
    Parlour(
      id: 'p2',
      name: 'Glam Studio',
      address: '456 Fashion Ave, City Center',
      phone: '+92-300-2345678',
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1596362051573-39ec8d93c321?w=500',
      description: 'Modern salon with latest beauty trends',
      services: [
        ParlourService(id: 's5', name: 'Makeup Artist', price: 4000, durationMinutes: 60),
        ParlourService(id: 's6', name: 'Hair Cut', price: 1000, durationMinutes: 30),
        ParlourService(id: 's7', name: 'Makeup Touch Up', price: 1000, durationMinutes: 20),
      ],
    ),
    Parlour(
      id: 'p3',
      name: 'Elite Beauty Parlour',
      address: '789 Luxury Plaza, Premium Area',
      phone: '+92-300-3456789',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1487412947529-14059e0cb69b?w=500',
      description: 'Luxury beauty and wellness center',
      services: [
        ParlourService(id: 's8', name: 'Bridal Package', price: 10000, durationMinutes: 180),
        ParlourService(id: 's9', name: 'Makeup + Hair', price: 6000, durationMinutes: 120),
        ParlourService(id: 's10', name: 'Spa Treatment', price: 3000, durationMinutes: 60),
      ],
    ),
    Parlour(
      id: 'p4',
      name: 'Fresh Look Salon',
      address: '321 High Street, Main Market',
      phone: '+92-300-4567890',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1612527904906-af305941b4a8?w=500',
      description: 'Affordable beauty services for everyone',
      services: [
        ParlourService(id: 's11', name: 'Basic Makeup', price: 1500, durationMinutes: 40),
        ParlourService(id: 's12', name: 'Hair Wash & Style', price: 800, durationMinutes: 30),
        ParlourService(id: 's13', name: 'Threading', price: 300, durationMinutes: 15),
      ],
    ),
    Parlour(
      id: 'p5',
      name: 'Radiant Spa',
      address: '654 Wellness Way, Resort Area',
      phone: '+92-300-5678901',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1570521944519-bbcc00b4azad?w=500',
      description: 'Complete skincare and beauty solutions',
      services: [
        ParlourService(id: 's14', name: 'Facial Treatment', price: 2000, durationMinutes: 45),
        ParlourService(id: 's15', name: 'Full Body Massage', price: 4000, durationMinutes: 60),
        ParlourService(id: 's16', name: 'Makeup Session', price: 2500, durationMinutes: 50),
      ],
    ),
  ];

  /// Get all parlours
  static Future<List<Parlour>> getParlours() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockParlours;
  }

  /// Get single parlour by ID
  static Future<Parlour?> getParlourById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockParlours.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search parlours by name
  static Future<List<Parlour>> searchParlours(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (query.isEmpty) return _mockParlours;

    final lowerQuery = query.toLowerCase();
    return _mockParlours
        .where((p) => p.name.toLowerCase().contains(lowerQuery) ||
            p.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get services for a parlour
  static Future<List<ParlourService?>> getServicesForParlour(String parlourId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final parlour = await getParlourById(parlourId);
    return parlour?.services ?? [];
  }

  /// Book service (mock implementation)
  static Future<bool> bookService({
    required String parlourId,
    required String serviceId,
    required String customerName,
    required String customerPhone,
    required String selectedDate,
    required String selectedTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In real app, this would call backend API
    print('✅ Booking confirmed: $customerName at $selectedDate $selectedTime');
    return true;
  }
}
