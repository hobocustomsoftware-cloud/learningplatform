import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../core/api_env.dart';

class WebRtcClient {
  RtcEngine? _engine;

  Future<void> init({
    required String roomName,
    required String token,
    required int uid,
    bool isHost = false,
  }) async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(appId: ApiEnv.agoraAppId));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("🌐 Web joined: ${connection.channelId}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("👥 Web user joined: $remoteUid");
        },
      ),
    );

    await _engine!.enableVideo();

    await _engine!.setClientRole(
      role: isHost
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    await _engine!.joinChannel(
      token: token,
      channelId: roomName,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leave() async {
    await _engine?.leaveChannel();
    await _engine?.release();
  }
}
