import 'dart:convert';
import 'dart:html';
import 'package:webtile38/src/fleet_editor/fleet_model.dart';
import 'package:webtile38/src/route_simulator/vehicle_path.dart';
import 'package:dartleaf/dartleaf.dart';

class DataStore {
  final fleet = <FleetGroup>[];
  final routeSim = <VehiclePath>[];

  DataStore() {
    load();
    final path = [
      LatLng(43.207046, 27.956257),
      LatLng(43.202479, 27.954025),
      LatLng(43.200602, 27.940636),
      LatLng(43.199976, 27.930508),
      LatLng(43.204731, 27.925959),
      LatLng(43.210987, 27.925358),
      LatLng(43.214865, 27.927761),
      LatLng(43.218493, 27.932482),
      LatLng(43.219244, 27.940378),
      LatLng(43.217868, 27.949734),
      LatLng(43.215866, 27.95188),
      LatLng(43.210612, 27.956686)
    ];
    routeSim.add(VehiclePath("route1", "group1", "car1", path));
  }

  void load() {
    fleet.clear();
    var store = window.localStorage;
    if (!store.containsKey('fleet')) return;

    Map data = jsonDecode(store['fleet']);
    for (var group in data.keys) {
      var item = FleetGroup(group);
      var vehicles = List<String>.from(data[group]);
      item.vehicles = vehicles;
      fleet.add(item);
    }
  }

  void save() {
    final json = <String, dynamic>{};
    for (var group in fleet) {
      json[group.name] = group.vehicles;
    }
    var store = window.localStorage;

    store['fleet'] = jsonEncode(json);
  }
}
