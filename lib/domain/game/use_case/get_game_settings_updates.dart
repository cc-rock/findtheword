import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/game_repository.dart';

class GetGameSettingsUpdates {
  GameRepository _gameRepository;

  GetGameSettingsUpdates(this._gameRepository);

  Stream<GameSettings> invoke(String gameId) {
    return _gameRepository.getSettingsUpdates(gameId);
  }
}