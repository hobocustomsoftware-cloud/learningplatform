import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../core/api_env.dart';

class EnrollmentsApi {
  EnrollmentsApi._();
  static final EnrollmentsApi instance = EnrollmentsApi._();

  /// Backend current contract:
  /// POST /api/enrollments/enroll/
  /// body = { "course": <id>, "course_id": <id> }
  Future<void> enroll(int courseId) async {
    final dio = DioClient.i().dio;
    final url = ApiEnv.api('/enrollments/enroll/');
    try {
      await dio.post(url, data: {'course': courseId, 'course_id': courseId});
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      final data = e.response?.data;
      throw Exception('Enroll failed ($code): ${data ?? e.message}');
    }
  }
}
