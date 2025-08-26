import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../core/api_env.dart';

class AuthApi {
  /// POST /users/register/
  static Future<Response> register({
    required String username,
    required String password,
    String? email,
    String? role, // 'student' | 'instructor' | 'admin'
  }) {
    final url = ApiEnv.api('/users/register/');
    return DioClient.i().dio.post(
      url,
      data: {
        'username': username,
        'password': password,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
      },
    );
  }

  /// POST /users/token/
  static Future<Response> tokenObtain({
    required String username,
    required String password,
  }) {
    final url = ApiEnv.api('/users/token/');
    return DioClient.i().dio.post(
      url,
      data: {'username': username, 'password': password},
    );
  }

  /// POST /users/token/refresh/
  static Future<Response> tokenRefresh({required String refresh}) {
    final url = ApiEnv.api('/users/token/refresh/');
    return DioClient.i().dio.post(url, data: {'refresh': refresh});
  }
}
