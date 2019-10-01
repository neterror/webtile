import 'package:meta/meta.dart';

abstract class OptionsEvent {
  String label;
  String text;
  OptionsEvent({this.label, this.text});
}

class PolygonOptionEvent extends OptionsEvent {
  PolygonOptionEvent({@required String label}) : super(label: label);
}

class RectangleOptionEvent extends OptionsEvent {
  RectangleOptionEvent({@required String label}) : super(label: label);
}

class CircleOptionEvent extends OptionsEvent {
  CircleOptionEvent({@required String label}) : super(label: label);
}

class SelectOptionEvent extends OptionsEvent {
  SelectOptionEvent({@required String label}) : super(label: label);
}

class RemoveOptionEvent extends OptionsEvent {
  RemoveOptionEvent({@required String label}) : super(label: label);
}

class EndOptionEvent extends OptionsEvent {}
