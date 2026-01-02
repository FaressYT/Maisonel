import 'dart:convert';
import 'dart:io';
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

  static String get storageUrl {
    return baseUrl.replaceAll('/api', '/storage');
  }

  static String? getImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http') || path.startsWith('https')) return path;
    if (path.startsWith('file://')) return path;
    return '$storageUrl/$path';
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
            .delete(
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
        return list.map((model) => Property.fromJson(model)).toList();
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
        return list.map((model) => Property.fromJson(model)).toList();
      } else {
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting available apartments: $e');
      throw Exception('Server communication error: $e');
    }
  }

  // --- 3. إدارة الطلبات للمالك (Owner Orders) ---

  static Future<List<Order>> getOwnerOrders() async {
    try {
      // التحقق من وجود توكن صالح قبل إرسال الطلبALL Orders
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

  // جلب تفاصيل طلب معين للمالك
  static Future<Order> getOwnerOrderDetails(int id) async {
    try {
      if (_token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/order/owner/show/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // قد تكون البيانات داخل data أو مباشرة، حسب تصميم الـ API
        // سنفترض أنها داخل data['data'] أو data كما هو معتاد
        return Order.fromJson(data['data'] ?? data);
      } else {
        throw Exception(
          'Failed to load order details: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Get Owner Order Details Error: $e');
      rethrow;
    }
  }

  // قبول طلب
  static Future<bool> approveOrder(int id) async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/order/owner/approve/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
          'Approve Order Failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Approve Order Error: $e');
      return false;
    }
  }

  // رفض طلب
  static Future<bool> rejectOrder(int id) async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/order/owner/reject/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
          'Reject Order Failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Reject Order Error: $e');
      return false;
    }
  }

  // تحديث قبول طلب (تغيير الحالة إلى مقبول لطلب سابق)
  static Future<bool> approveOrderUpdate(int id) async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/order/owner/approve_update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
          'Approve Update Failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Approve Update Error: $e');
      return false;
    }
  }

  // تحديث رفض طلب (تغيير الحالة إلى مرفوض لطلب سابق)
  static Future<bool> rejectOrderUpdate(int id) async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/order/owner/reject_update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
          'Reject Update Failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Reject Update Error: $e');
      return false;
    }
  }

  static Future<List<Order>> getMyBookings() async {
    try {
      if (_token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/user/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> ordersJson = responseData['data'] ?? [];
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('My Bookings Error: $e');
      return [];
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

  static Future<bool> updateApartment({
    required int id,
    required String city,
    required String size,
    required String title,
    required String description,
    required String price,
    required String bedrooms,
    required String bathrooms,
    required String type,
    required String location,
    List<File>? newImages,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/appartment/update/$id');

      // نستخدم POST دائماً مع MultipartRequest في تحديث الملفات
      var request = http.MultipartRequest('POST', uri);

      // إضافة الـ Headers مع التوكن
      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });

      // إخبار السيرفر (مثل Laravel) أن الطلب الحقيقي هو PUT
      request.fields['_method'] = 'PUT';

      // إضافة الحقول النصية
      request.fields.addAll({
        'city': city,
        'size': size,
        'title': title,
        'description': description,
        'price': price,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'type': type,
        'location': location,
      });

      // إضافة الصور الجديدة إن وجدت
      if (newImages != null && newImages.isNotEmpty) {
        for (var image in newImages) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image_url[]', // تأكد أن هذا الاسم يطابق ما ينتظره الباك إند
              image.path,
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Error Body: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Update Exception: $e");
      return false;
    }
  }

  static Future<bool> storeApartment({
    required String city,
    required String size,
    required String title,
    required String description,
    required String price,
    required String bedrooms,
    required String bathrooms,
    required String type,
    required String location,
    required List<File> images,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/appartment/store'),
      );

      // إضافة التوكن والترويسات
      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });

      // البيانات النصية
      request.fields.addAll({
        'city': city,
        'size': size,
        'title': title,
        'description': description,
        'price': price,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'type': type,
        'location': location,
      });

      // إضافة الصور
      for (var image in images) {
        request.files.add(
          await http.MultipartFile.fromPath('image_url[]', image.path),
        );
      }

      var response = await request.send();
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Property>> getMyListings() async {
    try {
      // الرابط الذي طلبته
      final url = Uri.parse('$baseUrl/appartment/index');

      // إرسال طلب GET مع التوكن
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // نرسل التوكن هنا ليعرف السيرفر من هو المستخدم
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        // تحويل البيانات القادمة من JSON إلى قائمة من كائنات Property
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        print("Error fetching my listings: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception while fetching listings: $e");
      return [];
    }
  }

  static Future<List<Property>> getMyApartments() async {
    try {
      // نفترض أن هذا الرابط يعيد عقارات الشخص صاحب التوكن
      final response = await http.get(
        Uri.parse('$baseUrl/appartment/my-listings'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((item) => Property.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 2. حذف عقار (destroy) حسب الـ ID والتوكن
  static Future<bool> deleteApartment(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/appartment/destroy/$id'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // تابع حذف صورة محددة من مصفوفة الصور لعقار معين
  static Future<bool> deleteApartmentImage(
    int propertyId,
    int imageIndex,
  ) async {
    try {
      // الرابط الديناميكي بناءً على طلبك
      final url = Uri.parse(
        '$baseUrl/appartment/images/$propertyId/index/$imageIndex',
      );

      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error deleting image: $e");
      return false;
    }
  }

  static Future<Property?> getApartmentById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appartment/show/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // استخدام التوكن المخزن في المتغير الثابت داخل الكلاس
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // استخراج البيانات (حسب هيكلية الـ JSON المتوقعة من Laravel)
        // إذا كانت البيانات داخل مفتاح 'data' نأخذها، وإلا نأخذ الرد كاملاً
        final data = responseData['data'] ?? responseData;

        return Property.fromJson(data);
      } else {
        debugPrint("Error fetching apartment $id: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Exception in getApartmentById: $e");
      return null;
    }
  }
}
