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

class ApiService {
  // قواعد بيانات الروابط حسب المنصة
  static const String _androidBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _iosBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _webBaseUrl = 'http://localhost:8000/api';

  // المتغيرات الثابتة لتخزين حالة الجلسة
  static String? _token;
  static User? currentUser;

  static String get baseUrl {
    if (kIsWeb) return _webBaseUrl;
    if (defaultTargetPlatform == TargetPlatform.android) return _androidBaseUrl;
    return _iosBaseUrl;
  }

  // --- 1. المصادقة (Authentication) ---

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // تخزين التوكن في المتغير الثابت لاستخدامه في الطلبات القادمة
        _token =
            (data['token'] ??
                data['Token'] ??
                data['access_token'] ??
                data['data']?['token']) ??
            _token;

        // تحليل بيانات المستخدم
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
        await http
            .get(
              Uri.parse('$baseUrl/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $_token',
              },
            )
            .timeout(const Duration(seconds: 10));
      }
    } finally {
      _token = null;
      currentUser = null;
    }
  }

  // --- 2. إدارة العقارات (Properties) ---

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        Iterable list = responseData['data'] ?? responseData;
        return list.map((model) => Property.fromJson(model)).toList();
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      throw Exception('Server communication error');
    }
  }

  static Future<List<Property>> filterProperties({
    String? query,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? propertyType,
    int? bedrooms,
    int? bathrooms,
  }) async {
    try {
      final Uri url = Uri.parse('$baseUrl/filter').replace(
        queryParameters: {
          if (query != null && query.isNotEmpty) 'search': query,
          if (location != null && location.isNotEmpty) 'location': location,
          if (minPrice != null) 'min_price': minPrice.toString(),
          if (maxPrice != null) 'max_price': maxPrice.toString(),
          if (propertyType != null && propertyType != 'All')
            'type': propertyType,
          if (bedrooms != null && bedrooms > 0) 'bedrooms': bedrooms.toString(),
          if (bathrooms != null && bathrooms > 0)
            'bathrooms': bathrooms.toString(),
        },
      );

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to filter properties');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- 3. إدارة الطلبات للمالك (Owner Orders) ---

  static Future<List<Order>> getOwnerOrders() async {
    try {
      // التحقق من وجود توكن صالح قبل إرسال الطلب
      if (_token == null) {
        throw Exception('User is not authenticated. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/order/owner/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Bearer $_token', // استخدام التوكن الحقيقي المخزن في الكلاس
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // جلب قائمة الطلبات من حقل 'data'
        final List<dynamic> ordersJson = responseData['data'] ?? [];

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

  // --- 4. تغيير كلمة المرور ---

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

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // تابع لجلب تفاصيل طلب واحد محدد باستخدام معرف الطلب
  static Future<Order> getOrderDetails(int orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/order/owner/show/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token', // إرسال التوكن للتحقق من الهوية
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // نفترض أن السيرفر يعيد الطلب داخل حقل يسمى 'data' أو يعيده مباشرة
      return Order.fromJson(data['data'] ?? data);
    } else {
      throw Exception('Failed to load order details: ${response.statusCode}');
    }
  }
}
