import 'package:webtile38/src/sketch_maker/shape.dart';
abstract class AreaState {}

class InitialAreaState extends AreaState {
  String toString() => "";
  InitialAreaState();
}

class AreaCreatedState extends AreaState {
  Shape shape;
  AreaCreatedState(this.shape);

  String toString() => "";
}

class AreaDrawInProgress extends AreaState {
  String message;
  AreaDrawInProgress(this.message);

  String toString() => message;
}
