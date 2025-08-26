// lib/core/perm.dart
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureAvPermissions() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  final mic = await Permission.microphone.request();
  final cam = await Permission.camera.request();
  if (mic.isPermanentlyDenied || cam.isPermanentlyDenied) {
    await openAppSettings();
  }
}
