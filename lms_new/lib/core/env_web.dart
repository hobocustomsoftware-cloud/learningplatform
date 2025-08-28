// lib/core/env_web.dart
// @JS('window')

String _envOrNull(String key) {
  try {
    // Flutter --dart-define values are compiled; prefer ApiEnv.dart reading if needed
    return const String.fromEnvironment('BACKEND_BASE', defaultValue: '');
  } catch (_) {
    return '';
  }
}

/// Web default: allow override, else 127.0.0.1:8000/api
String defaultBase() {
  final override = _envOrNull('BACKEND_BASE');
  if (override.isNotEmpty) return override;
  return 'http://127.0.0.1:8000/api';
}
