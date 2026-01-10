class Review {
  final String id;
  final String propertyId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerPhoto;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.propertyId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerPhoto,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    String firstName = '';
    String lastName = '';
    String? photo;
    if (user is Map<String, dynamic>) {
      firstName = user['first_name']?.toString() ?? '';
      lastName = user['last_name']?.toString() ?? '';
      final userPhoto = user['photo'];
      if (userPhoto is String && userPhoto.isNotEmpty) {
        photo = userPhoto;
      }
    }
    final fullName = [firstName, lastName]
        .where((part) => part.trim().isNotEmpty)
        .join(' ')
        .trim();

    return Review(
      id: json['id']?.toString() ?? '',
      propertyId:
          (json['appartment_id'] ?? json['apartment_id'] ?? '').toString(),
      reviewerId: json['user_id']?.toString() ?? '',
      reviewerName: fullName.isNotEmpty
          ? fullName
          : (json['user_name']?.toString() ?? 'Anonymous'),
      reviewerPhoto: photo,
      rating: _toDouble(json['rating']),
      comment: json['comment']?.toString() ?? '',
      date: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // Mock data generator
  static List<Review> getMockReviews() {
    return [
      Review(
        id: 'r1',
        propertyId: '1',
        reviewerId: 'user2',
        reviewerName: 'Alice Johnson',
        reviewerPhoto: 'https://i.pravatar.cc/150?u=a042581f4e29026024d',
        rating: 5.0,
        comment: 'Absolutely stunning apartment! The views are incredible.',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: 'r2',
        propertyId: '1',
        reviewerId: 'user3',
        reviewerName: 'Bob Smith',
        reviewerPhoto: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
        rating: 4.5,
        comment: 'Great location and very clean. Host was very responsive.',
        date: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Review(
        id: 'r3',
        propertyId: '2',
        reviewerId: 'user4',
        reviewerName: 'Carol White',
        rating: 4.0,
        comment: 'Nice studio, but a bit noisy at night.',
        date: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }
}
