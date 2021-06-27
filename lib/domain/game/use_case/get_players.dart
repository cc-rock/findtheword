import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/game/game_repository.dart';

class GetPlayers {
  GameRepository _gameRepository;

  GetPlayers(this._gameRepository);

  Future<List<Player>> invoke(String gameId) {
    return _gameRepository.getPlayers(gameId);
  }
}