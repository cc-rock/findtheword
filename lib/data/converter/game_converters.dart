import 'package:findtheword/data/dto/game_dtos.dart';
import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/round.dart';
import 'package:findtheword/domain/game/word.dart';

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

Round roundFromDto(String letter, RoundDTO dto) => Round(
  letter,
  dto.firstToFinish,
  Map.fromEntries(
      dto.playersWords.entries.map(
              (entry) => MapEntry(
                  entry.key,
                  entry.value.map((wordDto) => Word(wordDto.category, wordDto.word, wordDto.isValid, wordDto.sameAs, entry.key)).toList()
              )
      )
  )
);

