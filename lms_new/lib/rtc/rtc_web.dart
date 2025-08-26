import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../core/api_env.dart';
import 'rtc_client.dart';

/// A concrete implementation of RtcClient for the web platform using Jitsi Meet.
class WebRtcClient implements RtcClient {
  // Use a final instance of JitsiMeet to interact with the SDK.
  final JitsiMeet _jitsi = JitsiMeet();

  // Local state to track the mute status, initialized to false.
  bool _isAudioMuted = false;
  bool _isVideoMuted = false;

  // To fix the error, declare the 'participants' list here.
  // We'll use this list to store the IDs of participants who join the meeting.
  final List<String> participants = [];

  @override
  Future<void> init({
    required String roomName,
    required String subject,
    required bool
    isHost, // The isHost parameter is kept for signature consistency.
  }) async {
    debugPrint('Initializing Jitsi Meet for web...');

    // Create the conference options object.
    final opts = JitsiMeetConferenceOptions(
      room: roomName,
      serverURL: ApiEnv.jitsiDomain, // This should be your Jitsi server URL.
      // User information to be displayed in the meeting.
      userInfo: JitsiMeetUserInfo(
        displayName: ApiEnv.userDisplayName,
        email: ApiEnv.userEmail,
        avatar: ApiEnv.userAvatar,
      ),

      // Configuration overrides to customize the meeting behavior.
      configOverrides: {
        "subject": subject,
        "prejoinPageEnabled": true,
        "disableDeepLinking": true,
        "startWithAudioMuted": _isAudioMuted,
        "startWithVideoMuted": _isVideoMuted,
      },

      // Feature flags to enable or disable specific features.
      featureFlags: {"lobby-mode.enabled": false},
    );

    try {
      // Create the JitsiMeetEventListener with your custom logic.
      final listener = JitsiMeetEventListener(
        conferenceJoined: (url) {
          debugPrint("conferenceJoined: url: $url");
        },
        participantJoined: (email, name, role, participantId) {
          debugPrint(
            "participantJoined: email: $email, name: $name, role: $role, "
            "participantId: $participantId",
          );
          // Add the participant's ID to the list.
          if (participantId != null) {
            participants.add(participantId);
          }
        },
        readyToClose: () {
          debugPrint("readyToClose");
        },
        // It's good practice to also have an onError handler.
        onError: (err) {
          debugPrint("Web client encountered an error: $err");
        },
      );

      // Join the meeting with the specified options and the new listener.
      await _jitsi.join(opts, listener: listener);
    } catch (e) {
      debugPrint("Failed to join the Jitsi conference: $e");
    }
  }

  @override
  Widget composedView() {
    // For web, Jitsi renders in a separate browser window or iframe.
    return const SizedBox.shrink();
  }

  @override
  Future<void> toggleMic() async {
    _isAudioMuted = !_isAudioMuted;
    await _jitsi.setAudioMuted(_isAudioMuted);
  }

  @override
  Future<void> toggleCam() async {
    _isVideoMuted = !_isVideoMuted;
    await _jitsi.setVideoMuted(_isVideoMuted);
  }

  @override
  Future<void> toggleCamera() async {
    debugPrint("Web: toggleCamera() is not supported on this platform.");
  }

  @override
  Future<void> leave() => _jitsi.hangUp();

  @override
  void dispose() {
    debugPrint("Disposing of WebRtcClient.");
  }
}
