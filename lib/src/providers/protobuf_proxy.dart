import 'dart:async';
import 'dart:html';
import 'package:webtile38/src/gen/tile38.pb.dart';
import 'package:webtile38/src/providers/tile38_proto.dart';

class ProtobufProxy implements Tile38Proto {
  final _receivedCtrl = StreamController<Packet>.broadcast();
  Stream<Packet> get received => _receivedCtrl.stream;

  final String server;
  static const _defaultHost = 'ws://localhost:8888/';
  WebSocket _socket;
  ProtobufProxy({this.server = _defaultHost});
  final _subscriptions = <StreamSubscription>[];

  Future<bool> connect() async {
    _socket = WebSocket(_defaultHost);
    await _socket.onOpen.first;
    bool connected = _socket.readyState == WebSocket.OPEN;
    if (connected) {
      print("WebSocket connected");
      var s0 = _socket.onError.listen(_onError);
      var s1 = _socket.onMessage.listen(_onReceive);
      var s2 = _socket.onClose.listen(_onClosed);
      _subscriptions.addAll([s0, s1, s2]);
      _socket.binaryType = "arraybuffer";
    }
    return connected;
  }

  void _cleanup() {
    print("WebSocket disconnected");
    for (var s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
  }

  void _onError(Event msg) => _cleanup();
  void _onClosed(CloseEvent e) => _cleanup();
  void _onReceive(MessageEvent msg) {
    var data = msg.data.asUint8List();
    final packet = Packet.fromBuffer(data);
    _receivedCtrl.sink.add(packet);
  }

  void send(dynamic data) async {
    bool connected = (_socket is WebSocket) && (_socket.readyState == WebSocket.OPEN);
    if (!connected) {
      connected =  await connect();
    }
    if (!connected) {
      print("send abandoned. not connected with the server");
      return;
    }

    if (data is Packet) {
      _socket.send(data.writeToBuffer());
    } else if (data is String) {
      var packet = Packet()..genericCmd = GenericCommand();
      packet.genericCmd.command = data;
      _socket.send(packet.writeToBuffer());
    }
  }
}
