import 'dart:convert';
import 'dart:html';
import 'package:webtile38/src/fleet_editor/fleet_model.dart';

class DataStore {
  final fleet = <FleetGroup>[];
  DataStore() {
    load();
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
