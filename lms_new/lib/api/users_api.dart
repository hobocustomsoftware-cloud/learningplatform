// lib/api/users_api.dart
import 'package:dio/dio.dart';

import '../core/dio_client.dart';
import '../core/api_env.dart';

class AuthError implements Exception {
  final String message;
  AuthError([this.message = 'Unauthorized']);
  @override
  String toString() => message;
}

class UsersApi {
  UsersApi._();
  static final instance = UsersApi._();

  Future<Map<String, dynamic>> myProfile() async {
    try {
      final r = await DioClient.i().dio.get(ApiEnv.api('/users/me/'));
      return r.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthError();
      }
      rethrow;
    }
  }

  Future<String> myRole() async {
    final profile = await myProfile();
    return (profile['role']?.toString()) ?? 'student';
  }

  Future<String> myName() async {
    final profile = await myProfile();
    return (profile['name']?.toString()) ?? 'User';
  }

  Future<String?> myEmail() async {
    final profile = await myProfile();
    return profile['email']?.toString();
  }
}
