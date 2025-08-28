class ApiEnv {
  // BACKEND_BASE ကို --dart-define နဲ့ override လို့ရအောင်
  static const String _kBackendBaseOverride = String.fromEnvironment(
    'BACKEND_BASE',
    defaultValue: '',
  );

  /// HTTP base URL (override > default)
  static String get apiBase {
    if (_kBackendBaseOverride.isNotEmpty) return _kBackendBaseOverride;
    return "http://127.0.0.1:8000/api";
  }

  /// WebSocket base derived from apiBase (http→ws, https→wss)
  static String get wsBase {
    final http = apiBase;
    final scheme = http.startsWith('https') ? 'wss' : 'ws';
    return http.replaceFirst(RegExp(r'^https?'), scheme);
  }

  /// Convenience helpers
  static String api(String path) => '$apiBase$path';
  static String ws(String path) => '$wsBase$path';

  // ---------- Jitsi ----------

  /// Jitsi server URL - uses jitsiDomain for all platforms
  //// Domain used for the web SDK/IFrame.
  static const String jitsiDomain = 'meet.jit.si';

  /// Full server URL used by the native SDKs.
  static const String jitsiServerUrl = 'https://meet.jit.si';

  static const String userDisplayName = 'userDisplayName';
  static const String? userEmail = null;
  static const String? userAvatar = null;

  static const String agoraAppId = "ddf12d43c7f446aaaad63571b86f348d";
}
