// lib/features/classroom/room_screen.dart
import 'package:flutter/material.dart';

import '../../api/classroom_api.dart';
import '../../model/join_info.dart'; // ⬅️ JoinInfo.fromMap() here
import '../../rtc/rtc_client.dart'; // ⬅️ use RtcClient.make()

class RoomScreen extends StatefulWidget {
  const RoomScreen({
    super.key,
    required this.classId,
    required this.title,
    required this.isHost,
  });
  final int classId;
  final String title;
  final bool isHost;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late final RtcClient _rtc;
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    // ✅ single factory (selector/as imports မလို)
    _rtc = RtcClient.make();
    _boot();
  }

  Future<void> _boot() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      Map<String, dynamic> raw;

      if (widget.isHost) {
        // Host ကိုပဲ start ခေါ်မယ်—မရရင် (403/500) join ကို fallback
        try {
          raw = await ClassroomApi.instance.start(widget.classId);
        } catch (_) {
          raw = await ClassroomApi.instance.join(widget.classId);
        }
      } else {
        // Student は 常に join
        raw = await ClassroomApi.instance.join(widget.classId);
      }

      final info = JoinInfo.fromMap(raw);

      await _rtc.init(
        channel: info.channel,
        appId: info.appId,
        token: info.token,
        uid: info.uid,
        isHost: info.isHost, // backend ကမှန်ကန်စွာ is_host ပြန်ပေးတယ်
      );

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    // dispose() မှာ await မလုပ်ပါ
    _rtc.leave();
    _rtc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_err != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_err!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: _boot, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final controls = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: () {
            _rtc.toggleMic();
          }, // ⬅️ wrap Future<void>
          icon: const Icon(Icons.mic),
          tooltip: 'Mic',
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: () {
            _rtc.toggleCam();
          }, // ⬅️ wrap Future<void>
          icon: const Icon(Icons.videocam),
          tooltip: 'Camera',
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: () {
            _rtc.switchCamera();
          }, // ⬅️ wrap Future<void>
          icon: const Icon(Icons.cameraswitch),
          tooltip: 'Switch camera',
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await _rtc.leave();
            if (mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.call_end),
          tooltip: 'Leave',
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          // Agora renders into platform views (web/mobile)
          Expanded(child: _rtc.composedView()),
          const SizedBox(height: 8),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: controls,
            ),
          ),
        ],
      ),
    );
  }
}
