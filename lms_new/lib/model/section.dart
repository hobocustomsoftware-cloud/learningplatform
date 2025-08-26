import 'lesson.dart';

class Section {
  final int id;
  final String title;
  final int order;
  final List<Lesson> lessons;

  Section({
    required this.id,
    required this.title,
    required this.order,
    required this.lessons,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as int,
      title: json['title'] ?? '',
      order: json['order'] as int? ?? 0,
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((e) => Lesson.fromJson(e))
          .toList(),
    );
  }
}
