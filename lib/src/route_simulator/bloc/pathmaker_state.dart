import 'package:meta/meta.dart';
import 'package:webtile38/src/toolbox/bloc/toolbox_event.dart';

@immutable
abstract class PathmakerState {}

class PathmakerInactiveState extends PathmakerState {
  String toString() => "PathmakerInactiveState";
}

class PathmakerActiveState extends PathmakerState {
  String toString() => "PathmakerActiveState";
}

class PathmakerPosState extends PathmakerState {
  final double lat;
  final double lng;
  PathmakerPosState(this.lat, this.lng);
  String toString() =>
      "lat: ${lat.toStringAsFixed(5)}  lng: ${lng.toStringAsFixed(6)}";
}

class PathmakerPathNameState extends PathmakerState {}
