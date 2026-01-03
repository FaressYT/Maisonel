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
  final bool isActive;
  final int approvalStatus; // 0: Pending, 1: Approved, -1: Rejected
  final bool isFavorite;
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
    this.isActive = true,
    this.approvalStatus = 0,
    this.isFavorite = false,
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
      images: _parseList(json['image_url'] ?? json['images'] ?? json['image']),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: (json['size'] ?? 0).toDouble(),
      propertyType: json['property_type'] ?? 'Apartment',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      approvalStatus: int.tryParse(json['is_approved']?.toString() ?? '0') ?? 0,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
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
}
