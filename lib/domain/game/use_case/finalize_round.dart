import '../game_repository.dart';
import '../ongoing_round.dart';

class FinalizeRound {
  GameRepository _gameRepository;

  FinalizeRound(this._gameRepository);

  Future<void> invoke(String gameId) async {
    OngoingRound ongoingRound = await _gameRepository.getOngoingRound(gameId);
    await _gameRepository.saveRoundFirstToFinish(gameId, ongoingRound.letter, ongoingRound.finishingPlayerId);
    await _gameRepository.saveOngoingRound(gameId, null);
  }
}