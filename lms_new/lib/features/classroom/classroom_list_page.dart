import 'package:flutter/material.dart';
import '../../core/token_store.dart';
import '../../api/classroom_api.dart';
import '../../api/paged.dart';
import '../../api/users_api.dart';
import '../../model/live_class.dart';
import 'room_screen.dart';

class ClassroomListPage extends StatefulWidget {
  const ClassroomListPage({super.key});
  @override
  State<ClassroomListPage> createState() => _ClassroomListPageState();
}

class _ClassroomListPageState extends State<ClassroomListPage> {
  late Future<Paged<LiveClass>> _future;
  late Future<String> _role;

  @override
  void initState() {
    super.initState();
    _future = ClassroomApi.instance.listLiveClasses(page: 1);
    _role = UsersApi.instance.myRole();

    // initState() မှာ Future return မလုပ်ဘဲ post-frame မှာ redirect စစ်ရန်
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final access = await TokenStore.readAccess();
      if (access == null || access.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  // ignore: unused_element
  void _reload() {
    setState(() {
      _future = ClassroomApi.instance.listLiveClasses(page: 1);
      _role = UsersApi.instance.myRole();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _role,
      builder: (_, roleSnap) {
        final role = roleSnap.data ?? 'student';
        return Scaffold(
          appBar: AppBar(title: const Text('Live Classes')),
          floatingActionButton: (role == 'instructor' || role == 'admin')
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // create dialog ကို မျှော်မကြာခင် သင့်လိုအပ်သလို ပြန်ထည့်
                  },
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
                final msg = err is AuthError ? 'Please login.' : err.toString();
                return Center(child: Text(msg));
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
                              isHost: true,
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
