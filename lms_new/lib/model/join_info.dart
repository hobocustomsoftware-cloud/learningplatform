class JoinInfo {
  final String provider;
  final String appId;
  final String channel;
  final String token;
  final int uid;
  final bool isHost;

  JoinInfo({
    required this.provider,
    required this.appId,
    required this.channel,
    required this.token,
    required this.uid,
    required this.isHost,
  });

  factory JoinInfo.fromMap(Map<String, dynamic> j) {
    bool hasNonEmpty(String k) =>
        j.containsKey(k) && j[k] != null && j[k].toString().trim().isNotEmpty;

    final missing = <String>[
      if (!hasNonEmpty('provider')) 'provider',
      if (!hasNonEmpty('app_id')) 'app_id',
      if (!hasNonEmpty('channel')) 'channel',
      if (!hasNonEmpty('token')) 'token',
      if (!j.containsKey('uid')) 'uid',
      if (!j.containsKey('is_host')) 'is_host',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Join info missing/empty: ${missing.join(", ")}; got: $j',
      );
    }

    return JoinInfo(
      provider: j['provider'] as String,
      appId: j['app_id'] as String,
      channel: j['channel'] as String,
      token: j['token'] as String,
      uid: j['uid'] is int ? j['uid'] as int : int.parse(j['uid'].toString()),
      isHost: j['is_host'] == true || j['is_host'].toString() == 'true',
    );
  }
}
