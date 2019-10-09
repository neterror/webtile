abstract class PathmakerEvent {}

class PathmakerActiveEvent extends PathmakerEvent {}

class PathmakerInactiveEvent extends PathmakerEvent {}

class PathmakerPosEvent extends PathmakerEvent {
  final double lat;
  final double lng;
  PathmakerPosEvent(this.lat, this.lng);
}

class PathmakerPathNameEvent extends PathmakerEvent {}
