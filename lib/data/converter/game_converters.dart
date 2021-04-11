import 'package:findtheword/data/dto/game_dtos.dart';
import 'package:findtheword/domain/game/game.dart';

GameSettingsDTO gameSettingsToDTO(GameSettings settings) => GameSettingsDTO(
  settings.roundDurationSeconds,
  settings.finishWhenFirstPlayerFinishes,
  settings.graceSecondsOnFinish,
  settings.roundStartDelay,
  settings.letterPool
);

GameSettings gameSettingsFromDTO(GameSettingsDTO settings) => GameSettings(
    settings.roundDurationSeconds,
    settings.finishWhenFirstPlayerFinishes,
    settings.graceSecondsOnFinish,
    settings.roundStartDelay,
    settings.letterPool
);

