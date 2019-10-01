import 'package:webtile38/src/providers/http_proto.dart';

abstract class Tile38Proto {
  Tile38Proto({String server});
  Future<bool> connect();
  bool send(dynamic data);
  Stream<dynamic> get received;
}

Tile38Proto protocolFactory() {
  return HttpProto(); //for now
}