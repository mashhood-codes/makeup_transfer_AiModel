class Parlour {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double rating;
  final String imageUrl;
  final List<ParlourService> services;
  final String description;
  final bool isOpen;

  Parlour({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.rating,
    required this.imageUrl,
    required this.services,
    required this.description,
    this.isOpen = true,
  });

  factory Parlour.fromJson(Map<String, dynamic> json) {
    return Parlour(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/300x300',
      services: (json['services'] as List?)
          ?.map((s) => ParlourService.fromJson(s))
          .toList() ??
          [],
      description: json['description'] ?? '',
      isOpen: json['isOpen'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'rating': rating,
      'imageUrl': imageUrl,
      'services': services.map((s) => s.toJson()).toList(),
      'description': description,
      'isOpen': isOpen,
    };
  }
}

class ParlourService {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String description;

  ParlourService({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.description = '',
  });

  factory ParlourService.fromJson(Map<String, dynamic> json) {
    return ParlourService(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Service',
      price: (json['price'] ?? 0).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 30,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'description': description,
    };
  }
}
