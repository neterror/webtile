import 'package:webtile38/src/providers/http_proto.dart';
import 'package:webtile38/src/providers/protobuf_proxy.dart';

abstract class Tile38Proto {
  Tile38Proto({String server});
  Future<bool> connect();
  void send(dynamic data);
  Stream<dynamic> get received;
}

Tile38Proto protocolFactory() {
  //return HttpProto();
  return ProtobufProxy();
}
