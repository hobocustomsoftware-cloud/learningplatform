import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../core/api_env.dart';
import 'rtc_client.dart';

class MobileRtcClient implements RtcClient {
  final _jitsi = JitsiMeet();
  bool _audioMuted = false;
  bool _videoMuted = false;
  bool isHost = false;
  @override
  Future<void> init({
    required String roomName,
    required String subject,
    required bool isHost, // signature must match interface
  }) async {
    final opts = JitsiMeetConferenceOptions(
      room: roomName,
      serverURL: ApiEnv.jitsiDomain,
      userInfo: JitsiMeetUserInfo(
        displayName: ApiEnv.userDisplayName,
        email: ApiEnv.userEmail,
        avatar: ApiEnv.userAvatar,
      ),
      configOverrides: {
        "subject": subject,
        "prejoinPageEnabled": true,
        "startWithAudioMuted": _audioMuted,
        "startWithVideoMuted": _videoMuted,
      },
      featureFlags: {"lobby-mode.enabled": false},
    );

    await _jitsi.join(
      opts,
      listener: JitsiMeetEventListener(
        // ❗ some builds don’t expose onOpened → leave it out if it reds
        // onOpened: () => debugPrint("Mobile onOpened"),
        conferenceJoined: (url) => debugPrint("Mobile joined: $url"),
        conferenceTerminated: (url, error) =>
            debugPrint("Mobile terminated: $url, error: $error"),
        readyToClose: () => debugPrint("Mobile readyToClose"),
        participantJoined: (email, name, role, participantId) =>
            debugPrint("Mobile participantJoined: $name ($participantId)"),
        onError: (err) => debugPrint("Mobile onError: $err"),
      ),
    );
  }

  @override
  Widget composedView() => const Center(child: Text('Connected (mobile)'));

  @override
  Future<void> toggleMic() async {
    _audioMuted = !_audioMuted;
    await _jitsi.setAudioMuted(_audioMuted);
  }

  @override
  Future<void> toggleCam() async {
    _videoMuted = !_videoMuted;
    await _jitsi.setVideoMuted(_videoMuted);
  }

  @override
  Future<void> toggleCamera() => _jitsi.switchCamera();

  @override
  Future<void> leave() => _jitsi.hangUp();

  @override
  void dispose() {}
}
