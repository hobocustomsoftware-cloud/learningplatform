class Enrollment {
  final int id;
  final int courseId;
  final int userId;
  final double progress;
  final DateTime enrolledAt;

  Enrollment({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.progress,
    required this.enrolledAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] as int,
      courseId: json['course'] as int,
      userId: json['user'] as int,
      progress: (json['progress'] is int)
          ? (json['progress'] as int).toDouble()
          : double.tryParse(json['progress'].toString()) ?? 0.0,
      enrolledAt:
          DateTime.tryParse(json['enrolled_at'] ?? '') ?? DateTime.now(),
    );
  }
}
