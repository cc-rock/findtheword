import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/game_repository.dart';

class GetGameSettings {
  GameRepository _gameRepository;

  GetGameSettings(this._gameRepository);

  Future<GameSettings> invoke(String gameId) {
    return _gameRepository.getSettings(gameId);
  }
}