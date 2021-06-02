import 'package:findtheword/domain/game/game_repository.dart';

class GetCategories {
  GameRepository _gameRepository;

  GetCategories(this._gameRepository);

  Future<List<String>> invoke(String gameId) {
    return _gameRepository.getCategories(gameId);
  }
}