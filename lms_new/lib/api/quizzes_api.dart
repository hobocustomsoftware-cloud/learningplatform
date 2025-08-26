import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../core/api_env.dart';

class QuizzesApi {
  /// GET /quizzes/quizzes/?page=N
  static Future<Response> listQuizzes({int? page}) {
    final url = ApiEnv.api('/quizzes/quizzes/');
    return DioClient.i().dio.get(
      url,
      queryParameters: {if (page != null) 'page': page},
    );
  }

  /// POST /quizzes/quizzes/
  static Future<Response> createQuiz(Map<String, dynamic> data) {
    final url = ApiEnv.api('/quizzes/quizzes/');
    return DioClient.i().dio.post(url, data: data);
  }

  /// GET /quizzes/quizzes/{id}/
  static Future<Response> getQuiz(int id) {
    final url = ApiEnv.api('/quizzes/quizzes/$id/');
    return DioClient.i().dio.get(url);
  }

  /// PUT /quizzes/quizzes/{id}/
  static Future<Response> updateQuiz(int id, Map<String, dynamic> data) {
    final url = ApiEnv.api('/quizzes/quizzes/$id/');
    return DioClient.i().dio.put(url, data: data);
  }

  /// PATCH /quizzes/quizzes/{id}/
  static Future<Response> patchQuiz(int id, Map<String, dynamic> data) {
    final url = ApiEnv.api('/quizzes/quizzes/$id/');
    return DioClient.i().dio.patch(url, data: data);
  }

  /// DELETE /quizzes/quizzes/{id}/
  static Future<Response> deleteQuiz(int id) {
    final url = ApiEnv.api('/quizzes/quizzes/$id/');
    return DioClient.i().dio.delete(url);
  }

  /// POST /quizzes/quizzes/{id}/publish/
  static Future<Response> publishQuiz(int id, Map<String, dynamic> data) {
    final url = ApiEnv.api('/quizzes/quizzes/$id/publish/');
    return DioClient.i().dio.post(url, data: data);
  }

  /// POST /quizzes/attempts/
  static Future<Response> createAttempt(Map<String, dynamic> data) {
    final url = ApiEnv.api('/quizzes/attempts/');
    return DioClient.i().dio.post(url, data: data);
  }

  /// GET /quizzes/attempts/{id}/
  static Future<Response> getAttempt(String id) {
    final url = ApiEnv.api('/quizzes/attempts/$id/');
    return DioClient.i().dio.get(url);
  }

  /// POST /quizzes/attempts/{id}/submit/
  static Future<Response> submitAttempt(String id, Map<String, dynamic> data) {
    final url = ApiEnv.api('/quizzes/attempts/$id/submit/');
    return DioClient.i().dio.post(url, data: data);
  }

  /// GET /quizzes/certificates/?page=N
  static Future<Response> listCertificates({int? page}) {
    final url = ApiEnv.api('/quizzes/certificates/');
    return DioClient.i().dio.get(
      url,
      queryParameters: {if (page != null) 'page': page},
    );
  }

  /// GET /quizzes/certificates/{id}/
  static Future<Response> getCertificate(String id) {
    final url = ApiEnv.api('/quizzes/certificates/$id/');
    return DioClient.i().dio.get(url);
  }

  /// GET /quizzes/questions/?page=N
  static Future<Response> listQuestions({int? page}) {
    final url = ApiEnv.api('/quizzes/questions/');
    return DioClient.i().dio.get(
      url,
      queryParameters: {if (page != null) 'page': page},
    );
  }

  /// POST /quizzes/questions/
  static Future<Response> createQuestion(Map<String, dynamic> data) {
    final url = ApiEnv.api('/quizzes/questions/');
    return DioClient.i().dio.post(url, data: data);
  }

  /// GET /quizzes/questions/{id}/
  static Future<Response> getQuestion(int id) {
    final url = ApiEnv.api('/quizzes/questions/$id/');
    return DioClient.i().dio.get(url);
  }

  /// PUT /quizzes/questions/{id}/
  static Future<Response> updateQuestion(int id, Map<String, dynamic> data) {
    final url = ApiEnv.api('/quizzes/questions/$id/');
    return DioClient.i().dio.put(url, data: data);
  }

  /// PATCH /quizzes/questions/{id}/
  static Future<Response> patchQuestion(int id, Map<String, dynamic> data) {
    final url = ApiEnv.api('/quizzes/questions/$id/');
    return DioClient.i().dio.patch(url, data: data);
  }

  /// DELETE /quizzes/questions/{id}/
  static Future<Response> deleteQuestion(int id) {
    final url = ApiEnv.api('/quizzes/questions/$id/');
    return DioClient.i().dio.delete(url);
  }
}
