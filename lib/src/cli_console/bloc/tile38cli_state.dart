import 'dart:convert';

abstract class Tile38cliState {
  Tile38cliState([dynamic response]);
}

class InitialTile38cliState extends Tile38cliState {
  String toString() => "N/A";
}

class ResponseReceivedState extends Tile38cliState {
  dynamic _response;
  ResponseReceivedState([this._response]);

  @override
  String toString() {
    var encode = JsonEncoder.withIndent("     ");
    return encode.convert(_response);
  }
}
