class Lesson {
  final int id;
  final String title;
  final String videoUrl;
  final int duration;

  Lesson({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.duration,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      title: json['title'] ?? '',
      videoUrl: json['video_url'] ?? '',
      duration: json['duration'] as int? ?? 0,
    );
  }
}