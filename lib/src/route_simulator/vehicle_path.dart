import 'package:dartleaf/dartleaf.dart';

class VehiclePath {
  final LeafletMap _map;
  final String name;
  final List points;
  final String group;
  final String vehicleId;

  VehiclePath(this._map, this.name, this.group, this.vehicleId, this.points);
}
