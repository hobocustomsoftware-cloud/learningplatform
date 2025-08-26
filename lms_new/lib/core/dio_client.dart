// lib/core/dio_client.dart
import 'package:dio/dio.dart';
import '../core/api_env.dart';
import '../core/token_store.dart';

class DioClient {
  DioClient._();
  static final DioClient _i = DioClient._();
  static DioClient i() => _i;

  late final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: ApiEnv.apiBase, // eg: http://127.0.0.1:8000/api
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            headers: {'Accept': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await TokenStore.readAccess();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              } else {
                options.headers.remove('Authorization');
              }
              handler.next(options);
            },
          ),
        );
}
