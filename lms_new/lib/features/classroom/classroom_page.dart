// lib/features/classroom/classroom_page.dart
import 'package:flutter/material.dart';
import '../../api/users_api.dart';
import 'room_screen.dart';

class ClassroomPage extends StatefulWidget {
  const ClassroomPage({super.key, required this.classId});
  final int classId;

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  String _role = 'student';
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final r = await UsersApi.instance
          .myRole(); // 'admin' | 'instructor' | 'student'
      if (!mounted) return;
      setState(() {
        _role = r;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHost = _role == 'admin' || _role == 'instructor';

    return Scaffold(
      appBar: AppBar(title: const Text('Classroom')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _err != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_err!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _loadRole,
                    child: const Text('Retry'),
                  ),
                ],
              )
            : FilledButton.icon(
                icon: const Icon(Icons.videocam),
                label: Text(
                  isHost ? 'Start / Join live room' : 'Join live room',
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RoomScreen(
                        classId: widget.classId,
                        title: 'title',
                        isHost: isHost, // ✅
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
