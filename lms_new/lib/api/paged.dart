class Paged<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  Paged({required this.count, this.next, this.previous, required this.results});

  factory Paged.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) itemFromMap,
  ) {
    final items = (map['results'] as List? ?? [])
        .map((e) => itemFromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Paged<T>(
      count: (map['count'] ?? items.length) as int,
      next: map['next']?.toString(),
      previous: map['previous']?.toString(),
      results: items,
    );
  }
}
