// lib/model/live_class.dart

class LiveClass {
  final int id;
  final int courseId;
  final String instructor; // Added instructor field
  final String title;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool isLive;

  LiveClass({
    required this.id,
    required this.courseId,
    required this.instructor, // Added instructor field
    required this.title,
    this.startedAt,
    this.endedAt,
    this.isLive = false,
  });

  // ✅ local helper function to parse datetime safely
  static DateTime? _parseDT(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  factory LiveClass.fromMap(Map<String, dynamic> m) {
    return LiveClass(
      id: m['id'] is int ? m['id'] : int.tryParse('${m['id']}') ?? 0,
      courseId: m['course'] is int
          ? m['course']
          : int.tryParse('${m['course']}') ?? 0,
      instructor: (m['instructor'] ?? m['instructor_id'] ?? '')
          .toString(), // Handle both field names
      title: (m['title'] ?? '').toString(),
      startedAt: _parseDT(m['started_at']),
      endedAt: _parseDT(m['ended_at']),
      isLive: m['is_live'] == true || m['is_live']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'course': courseId,
    'instructor_id': instructor, // Use instructor_id for backend compatibility
    'title': title,
    'started_at': startedAt?.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'is_live': isLive,
  };
}
