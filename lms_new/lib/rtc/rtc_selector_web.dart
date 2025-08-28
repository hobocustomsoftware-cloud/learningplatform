// lib/rtc/rtc_selector_web.dart
import 'rtc_client.dart';
import 'rtc_agora.dart'; // သင် Agora နဲ့ပဲသွားမယ်ဆို ဒီလို

RtcClient createRtcClient() => AgoraRtcClient();

// (အကယ်၍ web ကို Jitsi နဲ့သွားချင်ရင်)
// import 'rtc_web.dart';
// RtcClient createRtcClient() => WebRtcClient();
