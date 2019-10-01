abstract class Tile38cliEvent {}

class Tile38CmdEvent implements Tile38cliEvent {
  String command;
  Tile38CmdEvent(this.command);
}