import 'section.dart';

class Course {
  final int id;
  final String title;
  final String description;
  final String instructor;
  final double price;
  final List<Section> sections;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.price,
    required this.sections,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((e) => Section.fromJson(e))
          .toList(),
    );
  }
}
