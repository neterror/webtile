import 'package:dartleaf/dartleaf.dart';
class VehiclePath {
  String name;
  List points;
  String group;
  String vehicleId;
  bool running = false;
  VehiclePath(this.name, this.group, this.vehicleId, this.points);
  VehiclePath.fromJson(Map jsonData){
    name  = jsonData["name"];
    group = jsonData["group"];
    vehicleId = jsonData["vehicleId"];
    points = jsonData["points"].map((p) => LatLng(p[0],p[1])).toList();
    
  }
  dynamic toJson(){
       var p = points.map((p) => [p.lat, p.lng]).toList();
      
      var item = <String, dynamic>{
        "name": name,
        "points": p,
        "group" : group,
        "vehicleId": vehicleId 
      };      
    return item;
  }
}
