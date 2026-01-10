import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:maisonel_v02/models/order.dart';
import 'package:maisonel_v02/models/property.dart';
import '../models/user.dart';

class LoginResult {
  final User user;
  final String? message;

  const LoginResult({required this.user, this.message});
}

class RatingSummary {
  final double averageRating;
  final int ratingsCount;

  const RatingSummary({required this.averageRating, required this.ratingsCount});
}

class ApiService {
  static const String _androidBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _iosBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _webBaseUrl = 'http://localhost:8000/api';

  static String? _token;
  static String? get token => _token;
  static User? currentUser;

  static String get baseUrl {
    if (kIsWeb) return _webBaseUrl;
    if (defaultTargetPlatform == TargetPlatform.android) return _androidBaseUrl;
    return _iosBaseUrl;
  }

  static String get storageUrl {
    return baseUrl.replaceAll('/api', '/storage');
  }

  static String? getImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http') || path.startsWith('https')) return path;
    if (path.startsWith('file://')) return path;
    return '$storageUrl/$path';
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static Future<List<Property>> _attachRatings(
    List<Property> properties,
  ) async {
    if (properties.isEmpty) return properties;
    final futures = properties.map((property) async {
      try {
        final summary = await getApartmentRatingSummary(property.id);
        if (summary == null) return property;
        return property.withRating(
          rating: summary.averageRating,
          reviewCount: summary.ratingsCount,
        );
      } catch (e) {
        debugPrint('Rating summary failed for ${property.id}: $e');
        return property;
      }
    }).toList();
    return Future.wait(futures);
  }

  static Future<LoginResult> login(String phone, String password) async {
    try {
      if (!phone.startsWith('09')) {
        throw Exception('Phone number must start with 09');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _token =
            (data['token'] ??
                data['Token'] ??
                data['access_token'] ??
                data['data']?['token']) ??
            _token;

        User user;
        final userData =
            data['user'] ??
            data['User'] ??
            data['data']?['user'] ??
            data['data'];
        user = User.fromJson(userData);

        currentUser = user;
        return LoginResult(
          user: user,
          message: data['message'] ?? data['Message'],
        );
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception('Connection failed: $e');
    }
  }

  static Future<User> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confirmPassword,
    required String birthDate,
    XFile? photo,
    XFile? idDocument,
  }) async {
    try {
      if (!phone.startsWith('09')) {
        throw Exception('Phone number must start with 09');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register'),
      );
      request.headers.addAll({'Accept': 'application/json'});

      request.fields.addAll({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'password': password,
        'password_confirmation': confirmPassword,
        'birth_date': birthDate,
      });

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: photo.name),
        );
      }

      if (idDocument != null) {
        final bytes = await idDocument.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'id_document',
            bytes,
            filename: idDocument.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token =
            data['token'] ?? data['access_token'] ?? data['data']?['token'];

        final userData = data['user'] ?? data['data']?['user'] ?? data['data'];
        currentUser = User.fromJson(userData);
        return currentUser!;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  static Future<void> logout() async {
    try {
      if (_token != null) {
        final response = await http
            .delete(
              Uri.parse('$baseUrl/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $_token',
              },
            )
            .timeout(const Duration(seconds: 10));
        print(response.body);
      }
    } finally {
      _token = null;
      currentUser = null;
    }
  }

  static Future<List<Property>> getAvailableApartments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/availableApartments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        Iterable list;
        if (data is Map<String, dynamic>) {
          list = data['data'] ?? [];
        } else if (data is Iterable) {
          list = data;
        } else {
          throw Exception('Unexpected response format');
        }
        final properties =
            list.map((model) => Property.fromJson(model)).toList();
        return await _attachRatings(properties);
      } else {
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting available apartments: $e');
      throw Exception('Server communication error: $e');
    }
  }

  static Future<List<Property>> getOwnedApartments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ownedApartments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        Iterable list;
        if (data is Map<String, dynamic>) {
          list = data['data'] ?? [];
        } else if (data is Iterable) {
          list = data;
        } else {
          throw Exception('Unexpected response format');
        }
        final properties =
            list.map((model) => Property.fromJson(model)).toList();
        return await _attachRatings(properties);
      } else {
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting owned apartments: $e');
      throw Exception('Server communication error: $e');
    }
  }

  static Future<void> createApartment({
    required String title,
    required String description,
    required double price,
    required double size,
    required String city,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required String type,
    required List<XFile> images,
    required List<String> amenities,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/apartment/create'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });

      request.fields.addAll({
        'title': title,
        'description': description,
        'price': price.toString(),
        'size': size.toInt().toString(), // Convert to integer
        'city': city,
        'location': location,
        'bedrooms': bedrooms.toString(),
        'bathrooms': bathrooms.toString(),
        'type': type,
      });

      for (var amenity in amenities) {
        request.files.add(
          http.MultipartFile.fromString('amenities[]', amenity),
        );
      }

      for (var image in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_url[]',
            image.path,
            filename: image.name,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      print(responseBody.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = jsonDecode(responseBody.body);
        throw Exception(data['message'] ?? 'Failed to create apartment');
      }
    } catch (e) {
      throw Exception('Create apartment failed: $e');
    }
  }

  static Future<void> updateApartment(
    String id, {
    String? title,
    String? description,
    double? price,
    double? size,
    String? location,
    String? type,
    int? bedrooms,
    int? bathrooms,
    String? city,
    List<String>? amenities,
    List<XFile>? images,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/apartment/update/$id'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });

      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (price != null) request.fields['price'] = price.toString();
      if (size != null) request.fields['size'] = size.toInt().toString();
      if (location != null) request.fields['location'] = location;
      if (type != null) request.fields['type'] = type;
      if (bedrooms != null) request.fields['bedrooms'] = bedrooms.toString();
      if (bathrooms != null) request.fields['bathrooms'] = bathrooms.toString();
      if (city != null) request.fields['city'] = city;
      request.fields['_method'] = 'POST';
      if (amenities != null) {
        for (var amenity in amenities) {
          request.files.add(
            http.MultipartFile.fromString('amenities[]', amenity),
          );
        }
      }

      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image_url[]',
              image.path,
              filename: image.name,
            ),
          );
        }
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      print(responseBody.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = jsonDecode(responseBody.body);
        throw Exception(data['message'] ?? 'Failed to update apartment');
      }
    } catch (e) {
      throw Exception('Update apartment failed: $e');
    }
  }

  static Future<void> deleteApartment(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/apartment/destroy/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete apartment');
      }
    } catch (e) {
      throw Exception('Delete apartment failed: $e');
    }
  }

  static Future<void> toggleApartmentStatus(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/apartment/toggle-status/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to toggle apartment status');
      }
    } catch (e) {
      throw Exception('Toggle apartment status failed: $e');
    }
  }

  static Future<Property> getApartmentDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/apartment/show/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final propertyData = data['data'] ?? data;
        return Property.fromJson(propertyData);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to get apartment details');
      }
    } catch (e) {
      throw Exception('Get apartment details failed: $e');
    }
  }

  static Future<void> recordApartmentView(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/apartment/view/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String message = 'Failed to record apartment view';
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          message = data['message'] ?? message;
        }
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('Record apartment view failed: $e');
    }
  }

  static Future<void> deleteApartmentImage(String id, int idx) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/apartment/images/$id/index/$idx'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete image');
      }
    } catch (e) {
      throw Exception('Delete image failed: $e');
    }
  }

  static Future<List<Order>> getOwnerOrders() async {
    try {
      if (_token == null) {
        throw Exception('User is not authenticated. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/order/owner/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> ordersJson = responseData['orders'] ?? [];
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load owner orders: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Owner Orders Error: $e');
      throw Exception('Error fetching orders: $e');
    }
  }

  static Future<void> approveOrder(String id) async {
    await _postVoid('$baseUrl/order/owner/approve/$id');
  }

  static Future<void> rejectOrder(String id) async {
    await _postVoid('$baseUrl/order/owner/reject/$id');
  }

  static Future<void> approveOrderUpdate(String id) async {
    await _postVoid('$baseUrl/order/owner/approve_update/$id');
  }

  static Future<void> rejectOrderUpdate(String id) async {
    await _postVoid('$baseUrl/order/owner/reject_update/$id');
  }

  static Future<void> _postVoid(String url) async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Operation failed');
      }
    } catch (e) {
      throw Exception('Operation failed: $e');
    }
  }

  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  static Future<Order> getOrderDetails(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/order/owner/show/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Order.fromJson(data['data'] ?? data);
    } else {
      throw Exception('Failed to load order details: ${response.statusCode}');
    }
  }

  static Future<void> createOrder({
    required String apartmentId,
    required int guestCount,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double pricePerNight,
    required double totalCost,
  }) async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/order/user/store'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'appartment_id': apartmentId,
          'guest_count': guestCount,
          'check_in_date': checkInDate.toIso8601String().substring(0, 10),
          'check_out_date': checkOutDate.toIso8601String().substring(0, 10),
          'price_per_night': pricePerNight,
          'total_cost': totalCost,
        }),
      );
      print(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      throw Exception('Booking failed: $e');
    }
  }

  static Future<void> updateOrderData(
    String id, {
    int? guestCount,
    DateTime? checkInDate,
    DateTime? checkOutDate,
  }) async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/order/user/update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          if (guestCount != null) 'guest_count': guestCount,
          if (checkInDate != null)
            'check_in_date': checkInDate.toIso8601String().substring(0, 10),
          if (checkOutDate != null)
            'check_out_date': checkOutDate.toIso8601String().substring(0, 10),
        }),
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to update booking');
      }
    } catch (e) {
      throw Exception('Update booking failed: $e');
    }
  }

  static Future<List<Order>> getUserOrders() async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/order/user/index'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> list = data['orders'] ?? data['data'] ?? [];
        return list.map((e) => Order.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load user orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get user orders failed: $e');
    }
  }

  static Future<Order> getUserOrderDetails(String id) async {
    try {
      if (_token == null) throw Exception('Not authenticated');
      final response = await http.get(
        Uri.parse('$baseUrl/order/user/show/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print(response.body + id);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get order details failed: $e');
    }
  }

  static Future<void> cancelUserOrder(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/order/user/cancle/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Cancel order failed: $e');
    }
  }

  static Future<List<DateTime>> getUnavailableDates(String apartmentId) async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/order/user/unavailable_dates/$apartmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final raw = data['unavailable_dates'];
          if (raw is List) {
            return raw
                .map((e) => DateTime.parse(e.toString()))
                .toList(growable: false);
          }
          final dataField = data['data'];
          if (dataField is List) {
            return dataField
                .map((e) => DateTime.parse(e.toString()))
                .toList(growable: false);
          }
          if (dataField is Map<String, dynamic>) {
            final nested = dataField['unavailable_dates'];
            if (nested is List) {
              return nested
                  .map((e) => DateTime.parse(e.toString()))
                  .toList(growable: false);
            }
          }
          if (raw is Map<String, dynamic>) {
            final nested =
                raw['unavailable_dates'] ?? raw['data'] ?? raw['dates'];
            if (nested is List) {
              return nested
                  .map((e) => DateTime.parse(e.toString()))
                  .toList(growable: false);
            }
          }
        }
        return [];
      }
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to load unavailable dates');
    } catch (e) {
      debugPrint('Error getting unavailable dates: $e');
      return [];
    }
  }

  static Future<void> rateOrder(String id, int rating) async {
    try {
      if (_token == null) throw Exception('Not authenticated');
      final response = await http.post(
        Uri.parse('$baseUrl/order/user/rate/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'rating': rating}),
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to rate order');
      }
    } catch (e) {
      throw Exception('Rate order failed: $e');
    }
  }

  static Future<void> toggleFavorite(String appId) async {
    await _postVoid('$baseUrl/favorites/toggle/$appId');
  }

  static Future<List<Property>> getFavorites() async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/favorites/index'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> list = data['favorites'] ?? [];
        return list.map((e) => Property.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      throw Exception('Get favorites failed: $e');
    }
  }

  static Future<void> storeRating(
    String orderId,
    int rating,
    String comment,
  ) async {
    try {
      if (_token == null) throw Exception('Not authenticated');
      final response = await http.post(
        Uri.parse('$baseUrl/rating/store/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'rating': rating, 'comment': comment}),
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to store rating');
      }
    } catch (e) {
      throw Exception('Store rating failed: $e');
    }
  }

  static Future<void> updateRating(
    String ratingId,
    int rating,
    String comment,
  ) async {
    try {
      if (_token == null) throw Exception('Not authenticated');
      final response = await http.post(
        Uri.parse('$baseUrl/rating/update/$ratingId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'rating': rating, 'comment': comment}),
      );
      print(response.body);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to update rating');
      }
    } catch (e) {
      throw Exception('Update rating failed: $e');
    }
  }

  static Future<List<dynamic>> getApartmentRatings(String apartmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rating/index/$apartmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final ratings = data['ratings'] ?? data['data'] ?? [];
          return ratings is List ? ratings : [];
        }
        if (data is List) return data;
        return [];
      } else {
        throw Exception('Failed to load ratings');
      }
    } catch (e) {
      debugPrint('Get ratings failed: $e');
      return [];
    }
  }

  static Future<RatingSummary?> getApartmentRatingSummary(
    String apartmentId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rating/index/$apartmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final source =
              data['data'] is Map<String, dynamic> ? data['data'] : data;
          return RatingSummary(
            averageRating: _toDouble(
              source['average_rating'] ?? source['average'] ?? source['rating'],
            ),
            ratingsCount: _toInt(
              source['ratings_count'] ??
                  source['count'] ??
                  source['review_count'],
            ),
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get rating summary failed: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getCreditCards() async {
    try {
      if (_token == null) throw Exception('Not authenticated');
      final response = await http.get(
        Uri.parse('$baseUrl/user/credit-cards'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        return data['credit_cards'] ?? [];
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      throw Exception('Get cards failed: $e');
    }
  }

  static Future<void> addCreditCard({
    required String holderName,
    required String cardNumber,
    required String expirationDate,
    required String cvv,
    required String cardType,
  }) async {
    try {
      if (_token == null) throw Exception('Not authenticated');
      final response = await http.post(
        Uri.parse('$baseUrl/user/credit-cards'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'card_holder_name': holderName,
          'card_number': cardNumber,
          'expiration_date': expirationDate,
          'cvv': cvv,
          'card_type': cardType,
        }),
      );
      print(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to add card');
      }
    } catch (e) {
      throw Exception('Add card failed: $e');
    }
  }

  static Future<String> deleteCreditCard(String id) async {
    try {
      if (_token == null) throw Exception('Not authenticated');
      final response = await http.delete(
        Uri.parse('$baseUrl/user/credit-cards/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print(response.body);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete card');
      }
      if (response.body.isEmpty) {
        return 'Card deleted';
      }
      final data = jsonDecode(response.body);
      final message = data['message']?.toString();
      return message == null || message.isEmpty ? 'Card deleted' : message;
    } catch (e) {
      throw Exception('Delete card failed: $e');
    }
  }
}
