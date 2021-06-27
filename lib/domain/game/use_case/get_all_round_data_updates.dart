import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/use_case/compute_num_duplicates.dart';

import '../round.dart';

class GetAllRoundDataUpdates {
  GameRepository _gameRepository;
  ComputeNumDuplicates _computeNumDuplicates;

  GetAllRoundDataUpdates(this._gameRepository, this._computeNumDuplicates);

  Stream<Round> invoke(String gameId, String letter) {
    return _gameRepository.getAllRoundDataUpdates(gameId, letter).map(
            (round) => _computeNumDuplicates.invoke(round)
    );
  }
}