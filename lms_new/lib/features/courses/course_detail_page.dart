import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/dio_client.dart';
import '../../core/api_env.dart';

class CourseDetailPage extends StatefulWidget {
  final int id;
  const CourseDetailPage({super.key, required this.id});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool _loading = true;
  String? _err;
  Map<String, dynamic>? _course;
  bool _enrolling = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final url = ApiEnv.api('/courses/courses/${widget.id}/');
      final res = await DioClient.i().dio.get(url);
      setState(() => _course = Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      setState(() => _err = e.response?.data?.toString() ?? e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _enroll() async {
    setState(() => _enrolling = true);
    try {
      final url = ApiEnv.api('/enrollments/enroll/');
      await DioClient.i().dio.post(
        url,
        data: {
          'course': widget.id, // ✅ add this
          'course_id': widget.id, // ✅ keep this too
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enrolled successfully')));
    } on DioException catch (e) {
      final msg =
          e.response?.data?.toString() ?? e.message ?? 'Failed to enroll';
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  Widget _sectionsView(List sections) {
    if (sections.isEmpty) {
      return const Text('No sections', style: TextStyle(color: Colors.white70));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final s = sections[i] as Map<String, dynamic>;
        final sTitle = (s['title'] ?? 'Section').toString();
        final lessons = (s['lessons'] as List?) ?? const [];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF151922),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (lessons.isEmpty)
                const Text(
                  'No lessons',
                  style: TextStyle(color: Colors.white60),
                )
              else
                ...lessons.map((l) {
                  final m = Map<String, dynamic>.from(l as Map);
                  final lTitle = (m['title'] ?? 'Lesson').toString();
                  final order = (m['order'] ?? '').toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_fill, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (order.isNotEmpty)
                          Text(
                            '#$order',
                            style: const TextStyle(color: Colors.white54),
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _err != null
        ? Center(
            child: Text(_err!, style: const TextStyle(color: Colors.red)),
          )
        : _course == null
        ? const Center(child: Text('Not found'))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _course!['title']?.toString() ?? 'Untitled',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _course!['description']?.toString() ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _chip('ID: ${_course!['id']}'),
                    if (_course!['price'] != null)
                      _chip('Price: ${_course!['price']}'),
                    if (_course!['status'] != null)
                      _chip('Status: ${_course!['status']}'),
                    if (_course!['category'] != null)
                      _chip('Category: ${_course!['category']}'),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _enrolling ? null : _enroll,
                  icon: _enrolling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.school),
                  label: const Text('Enroll'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sections',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _sectionsView((_course!['sections'] as List?) ?? const []),
                const SizedBox(height: 24),
                const SizedBox(height: 12),
              ],
            ),
          );

    return Scaffold(
      appBar: AppBar(title: Text('Course #${widget.id}')),
      body: body,
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF151922),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text),
    );
  }
}
