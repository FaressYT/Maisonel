import 'property.dart';

enum OrderStatus { pending, confirmed, completed, cancelled }

class Order {
  final String id;
  final Property property;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalCost;
  final OrderStatus status;
  final DateTime bookingDate;
  final int guests;

  Order({
    required this.id,
    required this.property,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalCost,
    required this.status,
    required this.bookingDate,
    required this.guests,
  });

  int get numberOfNights {
    return checkOutDate.difference(checkInDate).inDays;
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Mock data generator
  static List<Order> getMockOrders() {
    final properties = Property.getMockProperties();

    return [
      Order(
        id: 'order1',
        property: properties[0],
        checkInDate: DateTime.now().add(const Duration(days: 30)),
        checkOutDate: DateTime.now().add(const Duration(days: 37)),
        totalCost: 10500,
        status: OrderStatus.confirmed,
        bookingDate: DateTime.now().subtract(const Duration(days: 5)),
        guests: 2,
      ),
      Order(
        id: 'order2',
        property: properties[2],
        checkInDate: DateTime.now().subtract(const Duration(days: 30)),
        checkOutDate: DateTime.now().subtract(const Duration(days: 16)),
        totalCost: 44800,
        status: OrderStatus.completed,
        bookingDate: DateTime.now().subtract(const Duration(days: 60)),
        guests: 4,
      ),
      Order(
        id: 'order3',
        property: properties[1],
        checkInDate: DateTime.now().add(const Duration(days: 60)),
        checkOutDate: DateTime.now().add(const Duration(days: 67)),
        totalCost: 5600,
        status: OrderStatus.pending,
        bookingDate: DateTime.now().subtract(const Duration(days: 1)),
        guests: 1,
      ),
      Order(
        id: 'order4',
        property: properties[4],
        checkInDate: DateTime.now().subtract(const Duration(days: 90)),
        checkOutDate: DateTime.now().subtract(const Duration(days: 80)),
        totalCost: 25000,
        status: OrderStatus.completed,
        bookingDate: DateTime.now().subtract(const Duration(days: 120)),
        guests: 3,
      ),
      Order(
        id: 'order5',
        property: properties[3],
        checkInDate: DateTime.now().add(const Duration(days: 15)),
        checkOutDate: DateTime.now().add(const Duration(days: 18)),
        totalCost: 5400,
        status: OrderStatus.cancelled,
        bookingDate: DateTime.now().subtract(const Duration(days: 10)),
        guests: 2,
      ),
    ];
  }
}
