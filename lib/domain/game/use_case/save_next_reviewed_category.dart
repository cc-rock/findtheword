import 'package:findtheword/domain/game/game_repository.dart';

class SaveNextReviewedCategory {
  GameRepository _gameRepository;

  SaveNextReviewedCategory(this._gameRepository);

  Future<void> invoke(String gameId, int? categoryIndex) {
    return _gameRepository.setNextReviewedCategory(gameId, categoryIndex);
  }
}