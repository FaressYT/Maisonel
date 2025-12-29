import 'dart:ui' show Color;

import 'package:flutter/material.dart';

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

  // --- دوال الربط مع السيرفر (JSON Serialization) ---

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      // تحويل العقار المندمج داخل طلب البحث
      property: Property.fromJson(json['property']),
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: DateTime.parse(json['check_out_date']),
      totalCost: double.parse(json['total_cost'].toString()),
      // تحويل الحالة من نص (String) إلى Enum
      status: _statusFromString(json['status']),
      bookingDate: DateTime.parse(json['booking_date']),
      guests: int.parse(json['guests'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': property.id, // نرسل المعرف فقط عند الحجز
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'total_cost': totalCost,
      'status': status.name,
      'guests': guests,
    };
  }

  // دالة مساعدة لتحويل النص القادم من قاعدة البيانات إلى Enum
  static OrderStatus _statusFromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }

  // --- الدوال المحسوبة (Getters) ---

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

  // دالة لجلب لون الحالة (مفيدة في واجهة المستخدم)
  static Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
