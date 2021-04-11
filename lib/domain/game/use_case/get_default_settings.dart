import 'package:findtheword/domain/game/game.dart';

class GetDefaultSettings {
  GameSettings invoke() {
    return GameSettings(
      180, true, 3, 5,
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    );
  }
}