import 'package:webtile38/src/sketch_maker/shape.dart';

abstract class AreaEvent {
  AreaEvent();
}

class AreaCreatedEvent extends AreaEvent {
  Shape shape;
  AreaCreatedEvent(this.shape);
}

class AreaDrawEvent extends AreaEvent {
  String message;
  AreaDrawEvent(this.message);
}

class AreaSelected extends AreaEvent {}
