import 'package:findtheword/domain/game/game_repository.dart';

class GetNextReviewedCategoryUpdates {
  GameRepository _gameRepository;

  GetNextReviewedCategoryUpdates(this._gameRepository);

  Stream<int?> invoke(String gameId) {
    return _gameRepository.getNextReviewedCategoryUpdates(gameId);
  }
}