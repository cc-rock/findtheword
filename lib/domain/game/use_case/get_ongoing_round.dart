import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';

class GetOngoingRound {
  GameRepository _gameRepository;

  GetOngoingRound(this._gameRepository);

  Future<OngoingRound?> invoke(String gameId) {
    return _gameRepository.getOngoingRound(gameId);
  }
}