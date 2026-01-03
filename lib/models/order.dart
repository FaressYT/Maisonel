import 'dart:ui' show Color;

import 'package:flutter/material.dart';

import 'property.dart';

enum OrderStatus { pending, confirmed, completed, cancelled, rejected }

class Order {
  final String id;
  final String userId;
  final String apartmentId;
  final Property?
  property; // Property data might not be in the order list response
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalCost;
  final double pricePerNight;
  final OrderStatus status;
  final DateTime bookingDate; // Maps to created_at
  final int guests;
  final String? paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.apartmentId,
    this.property,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalCost,
    required this.pricePerNight,
    required this.status,
    required this.bookingDate,
    required this.guests,
    this.paymentMethod,
  });

  Order copyWith({
    String? id,
    String? userId,
    String? apartmentId,
    Property? property,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? totalCost,
    double? pricePerNight,
    OrderStatus? status,
    DateTime? bookingDate,
    int? guests,
    String? paymentMethod,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      apartmentId: apartmentId ?? this.apartmentId,
      property: property ?? this.property,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      totalCost: totalCost ?? this.totalCost,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      guests: guests ?? this.guests,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  // --- دوال الربط مع السيرفر (JSON Serialization) ---

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      apartmentId: json['appartment_id'].toString(),
      // Check if property object exists, otherwise null
      property: json['property'] != null
          ? Property.fromJson(json['property'])
          : null,
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: DateTime.parse(json['check_out_date']),
      totalCost: double.tryParse(json['total_cost'].toString()) ?? 0.0,
      pricePerNight: double.tryParse(json['price_per_night'].toString()) ?? 0.0,
      // تحويل الحالة من نص (String) إلى Enum
      status: _statusFromString(json['status']),
      bookingDate: DateTime.parse(json['created_at']),
      guests: int.tryParse(json['guest_count'].toString()) ?? 1,
      paymentMethod: json['payment_method']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'appartment_id': apartmentId,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'total_cost': totalCost,
      'price_per_night': pricePerNight,
      'status': status.name,
      'guest_count': guests,
      'created_at': bookingDate.toIso8601String(),
      'payment_method': paymentMethod,
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
      case OrderStatus.rejected:
        return 'Rejected';
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
      case OrderStatus.rejected:
        return Colors.red;
    }
  }
}
