class ToolboxEvent {
  String text;
  ToolboxEvent({this.text});
}

class ShowToolEvent extends ToolboxEvent {
  final List<int> position;
  ShowToolEvent(this.position);
}

class HideToolEvent extends ToolboxEvent {}

class MoveToolEvent extends ToolboxEvent {
  final List<int> position;
  MoveToolEvent(this.position);
}

class EndToolEvent extends ToolboxEvent {}
