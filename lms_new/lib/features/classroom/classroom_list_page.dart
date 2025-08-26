// lib/features/classroom/classroom_list_page.dart
import 'package:flutter/material.dart';
import '../../api/classroom_api.dart';
import '../../api/paged.dart';
import '../../api/users_api.dart';
import '../../model/live_class.dart';
import '../../core/token_store.dart';
import 'room_screen.dart';

class ClassroomListPage extends StatefulWidget {
  const ClassroomListPage({super.key});
  @override
  State<ClassroomListPage> createState() => _ClassroomListPageState();
}

class _ClassroomListPageState extends State<ClassroomListPage> {
  Future<Paged<LiveClass>>? _future;
  Future<String>? _role;

  @override
  void initState() {
    super.initState();
    // initState မှာ Future return မထွက်အောင်
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final access = await TokenStore.readAccess();
      if (!mounted) return;
      if (access == null || access.isEmpty) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      setState(() {
        _future = ClassroomApi.instance.listLiveClasses(page: 1);
        _role = UsersApi.instance.myRole();
      });
    });
  }

  Future<void> _boot() async {
    final access = await TokenStore.readAccess();
    if (!mounted) return;

    if (access == null || access.isEmpty) {
      // route ရှိနေရမယ် (section 3)
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _future = ClassroomApi.instance.listLiveClasses(page: 1);
      _role = UsersApi.instance.myRole();
    });
  }

  void _reload() {
    setState(() {
      _future = ClassroomApi.instance.listLiveClasses(page: 1);
      _role = UsersApi.instance.myRole();
    });
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final courseIdController = TextEditingController();
    final titleController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create Live Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: courseIdController,
                decoration: const InputDecoration(labelText: 'Course ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final courseId = int.tryParse(courseIdController.text);
                final title = titleController.text.trim();

                if (courseId == null || courseId <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid Course ID'),
                    ),
                  );
                  return;
                }

                if (title.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                Navigator.pop(ctx, {'courseId': courseId, 'title': title});
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      try {
        await ClassroomApi.instance.createLiveClass(
          courseId: result['courseId'] as int,
          title: result['title'] as String,
          startedAt: DateTime.now(),
        );
        _reload(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live class created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating live class: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_future == null || _role == null) {
      // booting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<String>(
      future: _role,
      builder: (_, roleSnap) {
        final role = roleSnap.data ?? 'student';
        return Scaffold(
          appBar: AppBar(title: const Text('Live Classes')),
          floatingActionButton: (role == 'instructor' || role == 'admin')
              ? FloatingActionButton.extended(
                  onPressed: () => _showCreateDialog(
                    context,
                  ), // Updated to show create dialog
                  label: const Text('Create'),
                )
              : null,
          body: FutureBuilder<Paged<LiveClass>>(
            future: _future,
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                final err = snap.error!;
                if (err is AuthError) {
                  // token မရှိ/မမှန် -> login
                  Future.microtask(() {
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  });
                  return const SizedBox.shrink();
                }
                return Center(child: Text(err.toString()));
              }
              final data = snap.data!;
              if (data.results.isEmpty) {
                return const Center(child: Text('No live classes'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: data.results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final c = data.results[i];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        c.isLive ? Icons.videocam : Icons.schedule,
                        color: c.isLive ? Colors.green : null,
                      ),
                      title: Text(c.title),
                      subtitle: Text('Course #${c.courseId} • Class #${c.id}'),
                      trailing: FilledButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoomScreen(
                              classId: c.id,
                              title: c.title,
                              isHost: role == 'admin' || role == 'instructor',
                            ),
                          ),
                        ),
                        child: const Text('Join'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
