class ToolboxState {
  bool visible = false;
  List<int> position = [0, 0];

  Map<String, bool> get htmlClass => {'shown': visible, 'hidden': !visible};

  Map<String, String> get htmlStyle =>
      {'left': '${position[0]}px', 'top': '${position[1]}px'};
}

class InactiveToolboxState extends ToolboxState {
  InitialToolboxState() {
    visible = false;
  }
}

class ActiveToolboxState extends ToolboxState {
  ActiveToolboxState(List<int> pos) {
    position = pos;
    visible = true;
  }
}
