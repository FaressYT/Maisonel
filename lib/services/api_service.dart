import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';

class LoginResult {
  final User user;
  final String? message;

  const LoginResult({required this.user, this.message});
}

class ApiService {
  static const String _androidBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _iosBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _webBaseUrl = 'http://localhost:8000/api';

  static String? _token;
  static User? currentUser;

  static String get baseUrl {
    if (kIsWeb) {
      return _webBaseUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidBaseUrl;
    }
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
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        debugPrint('Login response: ${response.body}');
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          _token =
              (data['token'] ??
                  data['Token'] ??
                  data['access_token'] ??
                  data['accessToken']) ??
              _token;
        }

        String? message;
        if (data is Map<String, dynamic>) {
          if (data['message'] is String) {
            message = data['message'];
          } else if (data['Message'] is String) {
            message = data['Message'];
          } else if (data['data'] is Map<String, dynamic> &&
              data['data']['message'] is String) {
            message = data['data']['message'];
          }
        }

        User user;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('user')) {
            user = User.fromJson(data['user']);
          } else if (data.containsKey('User')) {
            user = User.fromJson(data['User']);
          } else if (data.containsKey('data')) {
            final innerData = data['data'];
            if (innerData is Map<String, dynamic>) {
              if (innerData.containsKey('user')) {
                user = User.fromJson(innerData['user']);
              } else if (innerData.containsKey('User')) {
                user = User.fromJson(innerData['User']);
              } else {
                user = User.fromJson(innerData);
              }
            } else {
              throw Exception('Invalid data format');
            }
          } else {
            user = User.fromJson(data);
          }
          currentUser = user;
          debugPrint(
            'Current user: id=${user.id} name=${user.name} phone=${user.phone} photo=${user.profilePhoto}',
          );
          return LoginResult(user: user, message: message);
        } else {
          throw Exception('Invalid JSON format');
        }
      } else {
        debugPrint('Login failed (${response.statusCode}): ${response.body}');
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Login failed';
        throw Exception(message);
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
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register'),
      );
      request.headers.addAll({'Accept': 'application/json'});

      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = confirmPassword;
      request.fields['birth_date'] = birthDate;

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
        debugPrint('Register response: ${response.body}');
        debugPrint(
          'Registration failed (${response.statusCode}): ${response.body}',
        );
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          if (data.containsKey('token')) {
            _token = data['token'];
          } else if (data.containsKey('access_token')) {
            _token = data['access_token'];
          }
        }

        User user;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('user')) {
            user = User.fromJson(data['user']);
          } else if (data.containsKey('data')) {
            final inner = data['data'];
            if (inner is Map<String, dynamic> && inner.containsKey('user')) {
              user = User.fromJson(inner['user']);
            } else {
              user = User.fromJson(inner);
            }
          } else {
            user = User.fromJson(data);
          }
          currentUser = user;
          return user;
        }
        throw Exception('Registration successful but failed to parse user.');
      } else {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Registration failed';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          throw Exception(errors.values.first[0]);
        }
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('Registration error: $e');
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
      } else {
        debugPrint('Logout skipped: no token set');
      }
      debugPrint('Logout success');
      _token = null;
      currentUser = null;
    } catch (e) {
      debugPrint('Logout failed: $e');
      _token = null;
      currentUser = null;
    }
  }

  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
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
        debugPrint(
          'Change password failed (${response.statusCode}): ${response.body}',
        );
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Failed to change password';
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      throw Exception('Failed to change password: $e');
    }
  }
}
