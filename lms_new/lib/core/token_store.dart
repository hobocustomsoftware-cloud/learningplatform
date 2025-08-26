// lib/core/token_store.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  /// ✅ Access token ကိုသိမ်း
  static Future<void> writeAccess(String v) async {
    final p = await _prefs();
    await p.setString(_kAccess, v);
  }

  /// ✅ Refresh token ကိုသိမ်း
  static Future<void> writeRefresh(String v) async {
    final p = await _prefs();
    await p.setString(_kRefresh, v);
  }

  /// ✅ Access + Refresh တိုက်ရိုက် save
  static Future<void> save({
    required String access,
    required String refresh,
  }) async {
    final p = await _prefs();
    await p.setString(_kAccess, access);
    await p.setString(_kRefresh, refresh);
  }

  /// ✅ Helper: write both
  static Future<void> writeTokens({
    required String access,
    String? refresh,
  }) async {
    await writeAccess(access);
    if (refresh != null && refresh.isNotEmpty) {
      await writeRefresh(refresh);
    }
  }

  static Future<String?> readAccess() async {
    final p = await _prefs();
    return p.getString(_kAccess);
  }

  static Future<String?> readRefresh() async {
    final p = await _prefs();
    return p.getString(_kRefresh);
  }

  static Future<void> clear() async {
    final p = await _prefs();
    await p.remove(_kAccess);
    await p.remove(_kRefresh);
  }
}
