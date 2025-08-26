// lib/rtc/rtc_stub.dart (shared small helper, optional)
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef OnMessage = void Function(Map<String, dynamic>);

class Ws {
  WebSocketChannel? ch;
  void connect(Uri url, OnMessage onMsg) {
    ch = WebSocketChannel.connect(url);
    ch!.stream.listen((e) {
      onMsg(json.decode(e as String) as Map<String, dynamic>);
    });
  }

  void send(Map<String, dynamic> m) {
    ch?.sink.add(json.encode(m));
  }

  void close() {
    ch?.sink.close();
  }
}
