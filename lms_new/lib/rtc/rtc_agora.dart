// lib/rtc/rtc_agora.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../core/api_env.dart';
import 'rtc_client.dart';

class AgoraRtcClient implements RtcClient {
  RtcEngine? _engine;
  bool _audioMuted = false;
  bool _videoMuted = false;
  bool _joined = false;

  @override
  Future<void> init({
    required String roomName, // channelName
    required String subject,
    String? userName,
    String? userEmail,
    bool isHost = false,
    String? serverUrl, // unused for Agora
    String? token,
    int? uid,
  }) async {
    // 1) Initialize engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: ApiEnv.agoraAppId));

    // 2) Event handlers (debug)
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint("Agora joined: ${connection.channelId}");
          _joined = true;
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint("Remote joined: $remoteUid");
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint("Remote offline: $remoteUid, reason: $reason");
        },
        onError: (err, msg) {
          debugPrint("Agora error: $err, $msg");
        },
      ),
    );

    // 3) Role set
    await _engine!.setClientRole(
      role: isHost
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    // 4) Enable video
    await _engine!.enableVideo();

    // 5) Mobile camera/mic permissions
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // permission_handler ကို သင့် project style အလိုက် ခေါ်ပါ
      // await Permission.camera.request();
      // await Permission.microphone.request();
    }

    // 6) Join channel
    await _engine!.joinChannel(
      token: token ?? "",
      channelId: roomName,
      uid: uid ?? 0, // zero = let SDK pick
      options: const ChannelMediaOptions(),
    );

    // Host only: start preview & publish local stream
    if (isHost) {
      await _engine!.startPreview();
    }
  }

  @override
  Widget composedView() {
    // Minimal: show a note (for web you usually embed views via SurfaceView etc. — PoC skips)
    return Center(child: Text(_joined ? 'Connected (Agora)' : 'Connecting…'));
    // production: use AgoraVideoView for local/remote
  }

  @override
  Future<void> toggleMic() async {
    _audioMuted = !_audioMuted;
    await _engine?.muteLocalAudioStream(_audioMuted);
  }

  @override
  Future<void> toggleCam() async {
    _videoMuted = !_videoMuted;
    await _engine?.muteLocalVideoStream(_videoMuted);
  }

  // Mobile သာ switch camera ရနိုင်
  @override
  Future<void> toggleCamera() async {
    await _engine?.switchCamera();
  }

  @override
  Future<void> leave() async {
    await _engine?.leaveChannel();
    _joined = false;
  }

  @override
  void dispose() {
    _engine?.release();
    _engine = null;
  }
}
