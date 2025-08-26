// lib/api/classroom_api.dart
import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../model/live_class.dart';

class Paged<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;
  Paged({required this.count, this.next, this.previous, required this.results});
}

class ClassroomApi {
  ClassroomApi._();
  static final instance = ClassroomApi._();

  Future<Paged<LiveClass>> listLiveClasses({int page = 1}) async {
    final r = await DioClient.i().dio.get(
      '/classroom/live-classes/',
      queryParameters: {'page': page},
    );
    final map = Map<String, dynamic>.from(r.data as Map);
    final items = (map['results'] as List)
        .map((e) => LiveClass.fromMap(e))
        .toList();
    return Paged(
      count: map['count'] ?? items.length,
      next: map['next']?.toString(),
      previous: map['previous']?.toString(),
      results: items,
    );
  }

  Future<LiveClass> createLiveClass({
    required int courseId,
    required String title,
    bool isLive = true,
  }) async {
    final r = await DioClient.i().dio.post(
      '/classroom/live-classes/',
      data: {'course': courseId, 'title': title, 'is_live': isLive},
    );
    return LiveClass.fromMap(r.data);
  }

  Future<Map<String, String>> join(int classId) async {
    final r = await DioClient.i().dio.get(
      '/classroom/live-classes/$classId/join/',
    );
    final m = Map<String, dynamic>.from(r.data as Map);
    return {
      'room': (m['room'] ?? '').toString(),
      'subject': (m['subject'] ?? '').toString(),
    };
  }
}
