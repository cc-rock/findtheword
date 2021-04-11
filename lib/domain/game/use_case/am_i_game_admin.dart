import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/game/game_repository.dart';

class AmIGameAdmin {
  UserIdRepository _userIdRepository;
  GameRepository _gameRepository;

  AmIGameAdmin(this._userIdRepository, this._gameRepository);

  Future<Result<bool>> invoke(String gameId) async {
    try {
      String currentUserId = await _userIdRepository.currentUserId;
      String gameAdminId = await _gameRepository.getGameAdminId(gameId);
      return Result.success(currentUserId == gameAdminId);
    } catch(e) {
      return Future.value(Result.error(e));
    }
  }

}