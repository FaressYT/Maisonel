import 'dart:convert';

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String city;
  final String country;
  final List<String> images;
  final int bedrooms;
  final int bathrooms;
  final double area; // in square meters
  final String propertyType; // Apartment, House, Villa, Studio
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final String ownerId;
  final DateTime availableFrom;
  final List<String> amenities;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.city,
    required this.country,
    required this.images,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.propertyType,
    required this.rating,
    required this.reviewCount,
    this.isFeatured = false,
    required this.ownerId,
    required this.availableFrom,
    required this.amenities,
  });
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      // معالجة الصور سواء كانت نصاً واحداً أو قائمة
      images: _parseList(json['images'] ?? json['image']),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      propertyType: json['property_type'] ?? 'Apartment',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      ownerId: json['owner_id']?.toString() ?? '',
      availableFrom: json['available_from'] != null
          ? DateTime.parse(json['available_from'])
          : DateTime.now(),
      amenities: _parseList(json['amenities']),
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      // Check if it looks like a JSON array string
      if (value.startsWith('[') && value.endsWith(']')) {
        try {
          final decoded = List.from(
            jsonDecode(value),
          ).map((e) => e.toString()).toList();
          return decoded;
        } catch (_) {
          return [value];
        }
      }
      return [value];
    }
    return [value.toString()];
  }

  // Mock data generator
  // static List<Property> getMockProperties() {
  //   return [
  //     Property(
  //       id: '1',
  //       title: 'Modern Luxury Apartment',
  //       description:
  //           'A stunning modern apartment with city views and premium amenities.',
  //       price: 1500,
  //       location: 'Downtown District',
  //       city: 'New York',
  //       country: 'USA',
  //       images: [
  //         'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
  //         'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
  //       ],
  //       bedrooms: 2,
  //       bathrooms: 2,
  //       area: 95,
  //       propertyType: 'Apartment',
  //       rating: 4.8,
  //       reviewCount: 124,
  //       isFeatured: true,
  //       ownerId: 'owner1',
  //       availableFrom: DateTime.now(),
  //       amenities: ['WiFi', 'AC', 'Parking', 'Gym', 'Pool'],
  //     ),
  //     Property(
  //       id: '2',
  //       title: 'Cozy Studio in City Center',
  //       description:
  //           'Perfect for solo travelers or couples. Walking distance to everything.',
  //       price: 800,
  //       location: 'City Center',
  //       city: 'Los Angeles',
  //       country: 'USA',
  //       images: [
  //         'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
  //       ],
  //       bedrooms: 1,
  //       bathrooms: 1,
  //       area: 45,
  //       propertyType: 'Studio',
  //       rating: 4.5,
  //       reviewCount: 89,
  //       isFeatured: false,
  //       ownerId: 'owner2',
  //       availableFrom: DateTime.now().add(const Duration(days: 7)),
  //       amenities: ['WiFi', 'AC', 'Kitchen'],
  //     ),
  //     Property(
  //       id: '3',
  //       title: 'Spacious Family Villa',
  //       description: 'Beautiful villa with garden, perfect for families.',
  //       price: 3200,
  //       location: 'Suburban Area',
  //       city: 'Miami',
  //       country: 'USA',
  //       images: [
  //         'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
  //         'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
  //       ],
  //       bedrooms: 4,
  //       bathrooms: 3,
  //       area: 220,
  //       propertyType: 'Villa',
  //       rating: 4.9,
  //       reviewCount: 156,
  //       isFeatured: true,
  //       ownerId: 'owner3',
  //       availableFrom: DateTime.now(),
  //       amenities: ['WiFi', 'AC', 'Parking', 'Garden', 'BBQ', 'Pool'],
  //     ),
  //     Property(
  //       id: '4',
  //       title: 'Chic Loft Apartment',
  //       description:
  //           'Industrial-style loft with high ceilings and natural light.',
  //       price: 1800,
  //       location: 'Arts District',
  //       city: 'Chicago',
  //       country: 'USA',
  //       images: [
  //         'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
  //       ],
  //       bedrooms: 2,
  //       bathrooms: 1,
  //       area: 110,
  //       propertyType: 'Apartment',
  //       rating: 4.7,
  //       reviewCount: 92,
  //       isFeatured: false,
  //       ownerId: 'owner1',
  //       availableFrom: DateTime.now().add(const Duration(days: 14)),
  //       amenities: ['WiFi', 'AC', 'Parking', 'Pet Friendly'],
  //     ),
  //     Property(
  //       id: '5',
  //       title: 'Beachfront House',
  //       description:
  //           'Wake up to ocean views every morning in this beautiful beachfront property.',
  //       price: 2500,
  //       location: 'Beach Road',
  //       city: 'San Diego',
  //       country: 'USA',
  //       images: [
  //         'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=800',
  //         'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800',
  //       ],
  //       bedrooms: 3,
  //       bathrooms: 2,
  //       area: 150,
  //       propertyType: 'House',
  //       rating: 4.9,
  //       reviewCount: 203,
  //       isFeatured: true,
  //       ownerId: 'owner4',
  //       availableFrom: DateTime.now(),
  //       amenities: ['WiFi', 'AC', 'Beach Access', 'Parking', 'BBQ'],
  //     ),
  //     Property(
  //       id: '6',
  //       title: 'Urban Penthouse',
  //       description: 'Top floor penthouse with panoramic city views.',
  //       price: 4000,
  //       location: 'Financial District',
  //       city: 'New York',
  //       country: 'USA',
  //       images: [
  //         'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
  //       ],
  //       bedrooms: 3,
  //       bathrooms: 3,
  //       area: 180,
  //       propertyType: 'Apartment',
  //       rating: 5.0,
  //       reviewCount: 75,
  //       isFeatured: true,
  //       ownerId: 'owner5',
  //       availableFrom: DateTime.now().add(const Duration(days: 30)),
  //       amenities: ['WiFi', 'AC', 'Parking', 'Gym', 'Concierge', 'Rooftop'],
  //     ),
  //   ];
  // }
}
