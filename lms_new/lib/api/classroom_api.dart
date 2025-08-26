import 'paged.dart';
import '../core/api_env.dart';
import '../core/dio_client.dart';
import '../model/live_class.dart';

class ClassroomApi {
  ClassroomApi._();
  static final instance = ClassroomApi._();

  Future<Paged<LiveClass>> listLiveClasses({required int page}) async {
    final url = ApiEnv.api('/classroom/live-classes/?page=$page');
    final r = await DioClient.i().dio.get(url);
    return Paged.fromMap(
      Map<String, dynamic>.from(r.data as Map),
      LiveClass.fromMap,
    );
  }

  Future<LiveClass> createLiveClass({
    required int courseId,
    required String title,
    required DateTime startedAt,
    DateTime? endedAt,
    bool isLive = true,
  }) async {
    final url = ApiEnv.api('/classroom/live-classes/');
    final r = await DioClient.i().dio.post(
      url,
      data: {
        'course': courseId,
        'title': title,
        'started_at': startedAt.toIso8601String(),
        if (endedAt != null) 'ended_at': endedAt.toIso8601String(),
        'is_live': isLive,
        // instructor မလိုတော့ (backend HiddenField)
      },
    );
    return LiveClass.fromMap(Map<String, dynamic>.from(r.data as Map));
  }

  Future<Map<String, dynamic>> start(int id) async {
    final url = ApiEnv.api('/classroom/live-classes/$id/start/');
    final r = await DioClient.i().dio.post(url);
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> join(int id) async {
    final url = ApiEnv.api('/classroom/live-classes/$id/join/');
    final r = await DioClient.i().dio.post(url);
    return Map<String, dynamic>.from(r.data as Map);
  }
}
