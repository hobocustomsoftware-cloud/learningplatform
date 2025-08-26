import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/dio_client.dart';
import '../../core/api_env.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});
  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  bool _loading = true;
  String? _err;
  List<Map<String, dynamic>> _items = const [];
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetch(first: true);
  }

  Future<void> _fetch({bool first = false}) async {
    if (first) {
      setState(() {
        _loading = true;
        _err = null;
        _items = const [];
        _page = 1;
        _hasMore = true;
      });
    }
    try {
      final url = ApiEnv.api('/courses/courses/');
      final res = await DioClient.i().dio.get(
        url,
        queryParameters: {'page': _page},
      );
      final data = res.data as Map;
      final results = List<Map<String, dynamic>>.from(data['results'] as List);
      setState(() {
        _items = [..._items, ...results];
        _hasMore = data['next'] != null;
        _page += 1;
      });
    } on DioException catch (e) {
      setState(() => _err = e.response?.data?.toString() ?? e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _tile(Map<String, dynamic> it) {
    final id = it['id']?.toString() ?? '?';
    final title = (it['title'] ?? 'Untitled').toString();
    final price = (it['price'] ?? '').toString();
    final status = (it['status'] ?? '').toString();
    final category = it['category']?.toString();

    return ListTile(
      tileColor: const Color(0xFF151922),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (category != null) 'Category: $category',
          if (price.isNotEmpty) 'Price: $price',
          if (status.isNotEmpty) 'Status: $status',
          'ID: $id',
        ].where((e) => e.isNotEmpty).join(' • '),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        final intId = int.tryParse(id);
        if (intId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CourseDetailPage(id: intId)),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading && _items.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _err != null
        ? ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_err!, style: const TextStyle(color: Colors.red)),
              ),
            ],
          )
        : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length + (_hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              if (i == _items.length) {
                _fetch();
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _tile(_items[i]);
            },
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: RefreshIndicator(onRefresh: () => _fetch(first: true), child: body),
    );
  }
}
