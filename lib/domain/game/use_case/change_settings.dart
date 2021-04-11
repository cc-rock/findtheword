import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/game/game_repository.dart';

import '../game.dart';

class ChangeSettings {
  GameRepository _gameRepository;

  ChangeSettings(this._gameRepository);

  Future<Result<void>> invoke(String gameId, GameSettings settings) async {
    try {
      await _gameRepository.saveSettings(gameId, settings);
      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}