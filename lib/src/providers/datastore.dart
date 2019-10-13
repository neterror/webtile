import 'dart:convert';
import 'dart:html';
import 'package:webtile38/src/fleet_editor/fleet_model.dart';
import 'package:webtile38/src/route_simulator/vehicle_path.dart';

class DataStore {
  final fleet = <FleetGroup>[];
  final routeSim = <VehiclePath>[];

  DataStore() {
    load();
  }

  void load() {
    fleet.clear();
    var store = window.localStorage;
    if (!store.containsKey('routes')) return;
    var json = jsonDecode(store["routes"]); 
    for (var route in json["allroutes"]) {
      routeSim.add(VehiclePath.fromJson(route));
    }
  }

  void save() {
    final json = <String, dynamic>{"allroutes":[]};

    for (var path in routeSim) {
      json["allroutes"].add(path.toJson());
    }
    var store = window.localStorage;
    store['routes'] = jsonEncode(json);
  }
}
