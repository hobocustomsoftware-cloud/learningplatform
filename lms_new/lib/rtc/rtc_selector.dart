// lib/rtc/rtc_selector.dart
import 'rtc_client.dart';
import 'rtc_selector_stub.dart'
    if (dart.library.html) 'rtc_selector_web.dart'
    if (dart.library.io) 'rtc_selector_io.dart'
    as impl;

/// Use this everywhere
RtcClient makeRtcClient() => impl.createClient();
