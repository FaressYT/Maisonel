class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhoto;
  final DateTime joinedDate;
  final String bio;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhoto,
    required this.joinedDate,
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
}
