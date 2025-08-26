// lib/rtc/rtc_selector_stub.dart
import 'package:flutter/widgets.dart';

import 'rtc_client.dart';

class _NoRtc implements RtcClient {
  @override
  Future<void> init({
    required String roomName,
    required String subject,
    String? userName,
    String? userEmail,
    bool isHost = false,
  }) async {}
  @override
  Widget composedView() => const SizedBox.shrink();
  @override
  Future<void> toggleMic() async {}
  @override
  Future<void> toggleCam() async {}
  @override
  Future<void> toggleCamera() async {}
  @override
  Future<void> leave() async {}
  @override
  void dispose() {}
}

RtcClient createClient() => _NoRtc();
