enum NotificationType { orderUpdate, promotion, system, message }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  bool isRead;
  final NotificationType type;
  final String? data; // e.g., order ID or property ID

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
    required this.type,
    this.data,
  });

  // Mock data generator
  static List<AppNotification> getMockNotifications() {
    return [
      AppNotification(
        id: 'n1',
        title: 'Booking Confirmed',
        body: 'Your booking for "Modern Luxury Apartment" has been confirmed.',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.orderUpdate,
        data: 'order1',
      ),
      AppNotification(
        id: 'n2',
        title: 'New Message',
        body: 'You have a new message from the host.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: NotificationType.message,
      ),
      AppNotification(
        id: 'n3',
        title: 'Special Offer',
        body: 'Get 20% off your next booking in New York!',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.promotion,
      ),
      AppNotification(
        id: 'n4',
        title: 'Welcome to Maisonel',
        body: 'Thanks for joining our community. Start exploring now!',
        date: DateTime.now().subtract(const Duration(days: 10)),
        isRead: true,
        type: NotificationType.system,
      ),
    ];
  }
}
