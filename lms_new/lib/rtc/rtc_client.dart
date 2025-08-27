// lib/rtc/rtc_client.dart
import 'package:flutter/widgets.dart';

abstract class RtcClient {
  Future<void> init({
    required String roomName,
    required String subject,
    String? userName,
    String? userEmail,
    bool isHost = false,
    String? serverUrl,
    String? token,
  });
  Widget composedView();

  Future<void> toggleMic();
  Future<void> toggleCam();

  /// mobile မှာသာ camera ပြောင်းမယ်; web မှာ no-op လုပ်ပေးမယ်
  Future<void> toggleCamera();

  Future<void> leave();
  void dispose();
}
