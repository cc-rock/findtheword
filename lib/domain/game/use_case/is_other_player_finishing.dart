import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';

class IsOtherPlayerFinishing {
  UserIdRepository _userIdRepository;

  IsOtherPlayerFinishing(this._userIdRepository);

  Future<Result<bool>> invoke(OngoingRound ongoingRound) async {
    try {
      String currentUserId = await _userIdRepository.currentUserId;
      return Result.success(ongoingRound.finishingPlayerId != null && ongoingRound.finishingPlayerId != currentUserId);
    } catch(e) {
      return Future.value(Result.error(e));
    }
  }

}