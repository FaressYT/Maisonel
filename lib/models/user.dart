class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhoto;
  final String? idDocument;
  final DateTime joinedDate;
  final DateTime? birthDate;
  final String bio;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhoto,
    this.idDocument,
    required this.joinedDate,
    this.birthDate,
    this.bio = '',
    this.isVerified = false,
  });

  // Mock current user
  static User getMockUser() {
    return User(
      id: 'user1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+1 234 567 8900',
      profilePhoto:
          'https://ui-avatars.com/api/?name=John+Doe&size=200&background=00897B&color=fff',
      joinedDate: DateTime(2023, 1, 15),
      bio: 'Love traveling and exploring new places!',
      isVerified: true,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    String? name =
        _stringOrNull(json['name']) ??
        _stringOrNull(json['full_name']) ??
        _stringOrNull(json['fullName']);
    if ((name == null || name.isEmpty) &&
        (json['first_name'] != null || json['firstName'] != null)) {
      final firstName =
          _stringOrNull(json['first_name']) ?? _stringOrNull(json['firstName']);
      final lastName =
          _stringOrNull(json['last_name']) ?? _stringOrNull(json['lastName']);
      name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }

    return User(
      id: json['id'].toString(),
      name: name ?? '',
      email: _stringOrNull(json['email']) ?? '',
      phone:
          _stringOrNull(json['phone']) ??
          _stringOrNull(json['phone_number']) ??
          _stringOrNull(json['phoneNumber']) ??
          _stringOrNull(json['mobile']),
      profilePhoto:
          _stringOrNull(json['photo']) ??
          _stringOrNull(json['profile_photo_url']) ??
          _stringOrNull(json['profilePhoto']) ??
          _stringOrNull(json['photo_url']) ??
          _stringOrNull(json['avatar']),
      idDocument:
          _stringOrNull(json['id_document']) ??
          _stringOrNull(json['idDocument']),
      joinedDate: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      bio: _stringOrNull(json['bio']) ?? '',
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': profilePhoto,
      'id_document': idDocument,
      'created_at': joinedDate.toIso8601String(),
      'birth_date': birthDate?.toIso8601String(),
      'bio': bio,
      'is_verified': isVerified,
    };
  }
}
