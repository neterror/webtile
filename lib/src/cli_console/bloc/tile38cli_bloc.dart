import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:webtile38/src/providers/tile38_proto.dart';
import 'package:webtile38/src/gen/tile38.pb.dart';

class Tile38cliBloc extends Bloc<Tile38cliEvent, Tile38cliState> {
  Tile38Proto protocol;
  Tile38cliBloc({@required this.protocol});

  @override
  Tile38cliState get initialState => InitialTile38cliState();

  @override
  Stream<Tile38cliState> mapEventToState(
    Tile38cliEvent event,
  ) async* {
    if (event is Tile38CmdEvent) {
      protocol.send(event.command);
      final result = await protocol.received.first;
      if (result is Packet) {
        var data = result.genericResponse.response;
        yield ResponseReceivedState(data);
      } else {
        yield ResponseReceivedState(result);
      }
    }
  }
}
