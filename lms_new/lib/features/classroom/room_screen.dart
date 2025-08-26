// lib/features/classroom/room_screen.dart
import 'package:flutter/material.dart';
import '../../api/classroom_api.dart';
import '../../api/users_api.dart';
import '../../rtc/rtc_selector.dart'; // ✅ makeRtcClient() ရှိတဲ့ ဖိုင်

class RoomScreen extends StatefulWidget {
  const RoomScreen({
    super.key,
    required this.classId,
    required this.isHost, // <- prop နာမည်က isHost
    required this.title,
  });

  final int classId;
  final bool isHost;
  final String title;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _rtc = makeRtcClient(); // ✅ RtcClient.make() မဟုတ်ဘူး
  bool _initing = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    setState(() {
      _initing = true;
      _err = null;
    });
    try {
      final payload = widget.isHost
          ? await ClassroomApi.instance.start(widget.classId)
          : await ClassroomApi.instance.join(widget.classId);

      final room = (payload['room'] as String?) ?? 'room-${widget.classId}';
      final subject = (payload['subject'] as String?) ?? widget.title;

      // Get user information
      final userName = await UsersApi.instance.myName();
      final userEmail = await UsersApi.instance.myEmail();

      await _rtc.init(
        roomName: room,
        subject: subject,
        userName: userName,
        userEmail: userEmail,
        isHost: widget.isHost,
      );
    } catch (e) {
      _err = e.toString();
    } finally {
      if (mounted) setState(() => _initing = false);
    }
  }

  @override
  void dispose() {
    _rtc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Connecting...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_err != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meeting')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_err!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _boot, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.mic), onPressed: _rtc.toggleMic),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _rtc.toggleCam,
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _rtc.toggleCamera,
          ),
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: () async {
              await _rtc.leave();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _rtc.composedView(),
    );
  }
}
