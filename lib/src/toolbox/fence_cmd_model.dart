class FenceCmdModel {
  static const allowedCmd = <String>["nearby", "within", "intersects"];
  static const allowedDetection = <String>[
    "all",
    "enter",
    "exit",
    "inside",
    "outside",
    "cross"
  ];

  String channel; //user defined name
  String command; //nearby, intercect or within
  String group;  //user defined name
  String detection; //enter, leave
}
