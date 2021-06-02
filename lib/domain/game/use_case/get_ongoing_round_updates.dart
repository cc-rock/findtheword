import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';

import '../word.dart';

class GetOngoingRoundUpdates {
  GameRepository _gameRepository;

  GetOngoingRoundUpdates(this._gameRepository);

  Stream<OngoingRound> invoke(String gameId) {
    return _gameRepository.getOngoingRoundUpdates(gameId);
  }
}