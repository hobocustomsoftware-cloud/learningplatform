// lib/core/url.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

String _pickApiBase() {
  // Separate defines for web vs. mobile
  const webBase = String.fromEnvironment(
    'API_BASE_WEB',
    defaultValue: 'http://localhost:8000/api',
  );
  const mobileBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  return kIsWeb ? webBase : mobileBase;
}

/// Build absolute file URL from API_BASE, handling both absolute/relative paths.
String fileUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;

  final base = _pickApiBase();
  final origin = base.replaceFirst(RegExp(r'/api/?$'), '');
  final url = path.startsWith('/') ? '$origin$path' : '$origin/$path';

  // Debug: see exactly what we’re trying to load
  // debugPrint('🖼️ image url => $url');

  return url;
}

/// Shared thumbnail fallbacks
Widget thumbFallback() => Container(
  height: 90,
  width: double.infinity,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    gradient: const LinearGradient(
      colors: [Color(0xFF2A0F12), Color(0xFFE11D48)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  ),
);

Widget thumbFallbackSized(double w, double h) => Container(
  height: h,
  width: w,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    gradient: const LinearGradient(
      colors: [Color(0xFF2A0F12), Color(0xFFE11D48)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  ),
);
