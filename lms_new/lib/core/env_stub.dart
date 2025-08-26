// lib/core/env_stub.dart
import 'dart:io';

String defaultBase() {
  // Android Emulator maps host loopback to 10.0.2.2
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  // iOS Simulator / Desktop (Linux/Windows/macOS)
  if (Platform.isIOS ||
      Platform.isLinux ||
      Platform.isWindows ||
      Platform.isMacOS) {
    return 'http://127.0.0.1:8000';
  }
  // Fallback
  return 'http://127.0.0.1:8000';
}
