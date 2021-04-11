import 'package:findtheword/domain/game/game_repository.dart';

class GetCategoriesUpdates {
  GameRepository _gameRepository;

  GetCategoriesUpdates(this._gameRepository);

  Stream<List<String>> invoke(String gameId) {
    return _gameRepository.getCategoriesUpdates(gameId);
  }
}