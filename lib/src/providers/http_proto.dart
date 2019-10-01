import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'tile38_proto.dart';

class HttpProto implements Tile38Proto {
  final _receivedCtrl = StreamController<dynamic>.broadcast();
  Stream<dynamic> get received => _receivedCtrl.stream;

  final String server;
  static const _defaultHost = 'ws://localhost:9851/';
  WebSocket _socket;
  HttpProto({this.server = _defaultHost});
  final _subscriptions = <StreamSubscription>[];

  @override
  Future<bool> connect() async => true; //Tile38 WebSocket server closes immediately after finishing the request. The connection is useless

  void _cleanup() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
  }

  void _onError(Event msg) => _cleanup();
  void _onClosed(CloseEvent e) => _cleanup();
  void _onReceive(MessageEvent msg) {
    var response = jsonDecode(msg.data);
    _receivedCtrl.sink.add(response);
  }

  @override
  bool send(dynamic msg) {
    String cmd = msg;
    cmd.replaceAll(" ", "+");
    print("execute command: $cmd");
    String url = "${server}${cmd}";
    _socket = WebSocket(url);

    var s0 = _socket.onError.listen(_onError);
    var s1 = _socket.onMessage.listen(_onReceive);
    var s2 = _socket.onClose.listen(_onClosed);
    _subscriptions.addAll([s0, s1, s2]);
    return false;
  }
}
