// lib/rtc/rtc_agora.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'rtc_client.dart';

class AgoraRtcClient implements RtcClient {
  final _remoteUids = <int>{};
  final _uidsStream = StreamController<Set<int>>.broadcast();
  late final RtcEngine _engine;
  bool _micMuted = false, _camMuted = false;
  int? _uid;
  String? _channel;

  @override
  Future<void> init({
    required String channel,
    required String appId,
    required String token,
    required int uid,
    required bool isHost,
  }) async {
    _uid = uid;
    _channel = channel;

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection c, int elapsed) {
          debugPrint('Agora joined: ${c.channelId}');
        },
        onUserJoined: (RtcConnection c, int remoteUid, int elapsed) {
          _remoteUids.add(remoteUid);
          _uidsStream.add({..._remoteUids});
        },
        onUserOffline:
            (RtcConnection c, int remoteUid, UserOfflineReasonType r) {
              _remoteUids.remove(remoteUid);
              _uidsStream.add({..._remoteUids});
            },
        onError: (ErrorCodeType code, String msg) {
          debugPrint('Agora error: $code $msg');
        },
      ),
    );

    await _engine.enableVideo();

    // role
    await _engine.setClientRole(
      role: isHost
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    // Host publish his tracks, audience subscribe only
    final opts = ChannelMediaOptions(
      publishCameraTrack: isHost,
      publishMicrophoneTrack: isHost,
      autoSubscribeAudio: true,
      autoSubscribeVideo: true,
    );

    if (isHost) {
      await _engine.startPreview();
    }

    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: uid,
      options: opts,
    );
  }

  // A simple composed view: local on top-left (if host), remotes in a grid.
  @override
  Widget composedView() {
    return StreamBuilder<Set<int>>(
      stream: _uidsStream.stream,
      initialData: const {},
      builder: (_, snap) {
        final remotes = snap.data!.toList();
        final tiles = <Widget>[];

        // local view (only for host/broadcaster)
        tiles.add(
          Container(
            color: Colors.black,
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0), // local
              ),
            ),
          ),
        );

        // remote views
        for (final uid in remotes) {
          tiles.add(
            Container(
              color: Colors.black,
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(uid: uid),
                  connection: RtcConnection(channelId: _channel),
                ),
              ),
            ),
          );
        }

        // simple grid
        final cross = tiles.length <= 2 ? 1 : 2;
        return GridView.count(
          crossAxisCount: cross,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: tiles,
        );
      },
    );
  }

  @override
  Future<void> toggleMic() async {
    _micMuted = !_micMuted;
    await _engine.muteLocalAudioStream(_micMuted);
  }

  @override
  Future<void> toggleCam() async {
    _camMuted = !_camMuted;
    await _engine.muteLocalVideoStream(_camMuted);
  }

  @override
  Future<void> switchCamera() => _engine.switchCamera();

  @override
  Future<void> leave() async {
    await _engine.leaveChannel();
    await _engine.stopPreview();
  }

  @override
  void dispose() {
    _uidsStream.close();
    _engine.release();
  }
}
