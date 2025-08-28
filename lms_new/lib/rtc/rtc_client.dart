// lib/rtc/rtc_client.dart
import 'package:flutter/widgets.dart';
import 'rtc_selector.dart' show makeRtcClient;

abstract class RtcClient {
  Future<void> init({
    // Agora standard
    required String channel,
    required String appId,
    required String token,
    required int uid,
    required bool isHost,
  });

  Widget composedView();

  Future<void> toggleMic();
  Future<void> toggleCam();
  Future<void> switchCamera();
  Future<void> leave();
  void dispose();

  // ✅ single factory entry
  static RtcClient make() => makeRtcClient();
}
