import 'dart:math';

import 'package:findtheword/data/game_repository_impl.dart';
import 'package:findtheword/data/room_repository_impl.dart';
import 'package:findtheword/data/user_id_repository_impl.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/use_case/add_category.dart';
import 'package:findtheword/domain/game/use_case/am_i_game_admin.dart';
import 'package:findtheword/domain/game/use_case/change_settings.dart';
import 'package:findtheword/domain/game/use_case/compute_num_duplicates.dart';
import 'package:findtheword/domain/game/use_case/compute_word_points.dart';
import 'package:findtheword/domain/game/use_case/create_game.dart';
import 'package:findtheword/domain/game/use_case/delete_category.dart';
import 'package:findtheword/domain/game/use_case/finalize_round.dart';
import 'package:findtheword/domain/game/use_case/finish_round.dart';
import 'package:findtheword/domain/game/use_case/get_all_round_data_updates.dart';
import 'package:findtheword/domain/game/use_case/get_next_reviewed_category_updates.dart';
import 'package:findtheword/domain/game/use_case/get_ongoing_round.dart';
import 'package:findtheword/domain/game/use_case/get_players.dart';
import 'package:findtheword/domain/game/use_case/get_scoreboard.dart';
import 'package:findtheword/domain/game/use_case/save_all_round_data.dart';
import 'package:findtheword/domain/game/use_case/save_next_reviewed_category.dart';
import 'package:findtheword/domain/game/use_case/save_round_data.dart';
import 'package:findtheword/domain/game/use_case/finish_round_early.dart';
import 'package:findtheword/domain/game/use_case/get_categories.dart';
import 'package:findtheword/domain/game/use_case/get_categories_updates.dart';
import 'package:findtheword/domain/game/use_case/get_default_settings.dart';
import 'package:findtheword/domain/game/use_case/get_game_settings.dart';
import 'package:findtheword/domain/game/use_case/get_game_settings_updates.dart';
import 'package:findtheword/domain/game/use_case/get_ongoing_round_updates.dart';
import 'package:findtheword/domain/game/use_case/is_other_player_finishing.dart';
import 'package:findtheword/domain/game/use_case/start_round.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';
import 'package:findtheword/domain/join_room/use_case/am_i_room_admin.dart';
import 'package:findtheword/domain/join_room/use_case/create_room.dart';
import 'package:findtheword/domain/join_room/use_case/get_room_player_updates.dart';
import 'package:findtheword/domain/join_room/use_case/get_room_status.dart';
import 'package:findtheword/domain/join_room/use_case/is_room_complete.dart';
import 'package:findtheword/domain/join_room/use_case/join_room.dart';
import 'package:findtheword/domain/join_room/use_case/set_room_unavailable.dart';
import 'package:findtheword/firebase/db_wrapper.dart';
import 'package:findtheword/firebase/db_wrapper_factory.dart'
    if (dart.library.io) 'package:findtheword/firebase/mobile/mobile_db_wrapper_factory.dart'
    if (dart.library.js) 'package:findtheword/firebase/web/web_db_wrapper_factory.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Injector {

  Map<String, dynamic> _cache = {};

  DbWrapper get _dbWrapper => _getCached(() => DbWrapperFactory.getDbWrapper());

  UserIdRepository get userIdRepository => UserIdRepositoryImpl(FirebaseAuth.instance);

  RoomRepository get roomRepository => _getCached(() => RoomRepositoryImpl(_dbWrapper));

  GetRoomStatus get getRoomStatus => _getCached(() => GetRoomStatus(roomRepository));

  JoinRoom get joinRoom => _getCached(() => JoinRoom(userIdRepository, roomRepository));

  CreateRoom get createRoom => _getCached(() => CreateRoom(roomRepository, userIdRepository));

  GetRoomUpdates get getRoomPlayerUpdates => _getCached(() => GetRoomUpdates(roomRepository));

  AmIRoomAdmin get amIRoomAdmin => _getCached(() => AmIRoomAdmin(userIdRepository, roomRepository));

  IsRoomComplete get isRoomComplete => _getCached(() => IsRoomComplete());

  GameRepository get gameRepository => _getCached(() => GameRepositoryImpl(_dbWrapper));

  AddCategory get addCategory => _getCached(() => AddCategory(gameRepository));

  DeleteCategory get deleteCategory => _getCached(() => DeleteCategory(gameRepository));

  GetDefaultSettings get getDefaultSettings => _getCached(() => GetDefaultSettings());

  ChangeSettings get changeSettings => _getCached(() => ChangeSettings(gameRepository));

  GetCategoriesUpdates get getCategoriesUpdates => _getCached(() => GetCategoriesUpdates(gameRepository));

  GetCategories get getCategories => _getCached(() => GetCategories(gameRepository));

  GetGameSettingsUpdates get getGameSettingsUpdates => _getCached(() => GetGameSettingsUpdates(gameRepository));

  GetGameSettings get getGameSettings => _getCached(() => GetGameSettings(gameRepository));

  CreateGame get createGame => _getCached(() => CreateGame(gameRepository, getDefaultSettings, userIdRepository));

  AmIGameAdmin get amIGameAdmin => _getCached(() => AmIGameAdmin(userIdRepository, gameRepository));

  SetRoomUnavailable get setRoomUnavailable => _getCached(() => SetRoomUnavailable(roomRepository));

  GetOngoingRoundUpdates get getOngoingRoundUpdates => _getCached(() => GetOngoingRoundUpdates(gameRepository));

  IsOtherPlayerFinishing get isOtherPlayerFinishing => _getCached(() => IsOtherPlayerFinishing(userIdRepository));

  SaveRoundData get saveRoundData => _getCached(() => SaveRoundData(gameRepository, userIdRepository));

  FinishRound get finishRound => _getCached(() => FinishRound(saveRoundData));

  FinishRoundEarly get finishRoundEarly => _getCached(() => FinishRoundEarly(gameRepository, userIdRepository, finishRound));

  StartRound get startRound => _getCached(() => StartRound(
      gameRepository,
      () => DateTime.now().millisecondsSinceEpoch,
      (max) => _random.nextInt(max))
  );

  GetOngoingRound get getOngoingRound => _getCached(() => GetOngoingRound(gameRepository));
  GetNextReviewedCategoryUpdates get getNextReviewedCategoryUpdates => _getCached(() => GetNextReviewedCategoryUpdates(gameRepository));
  SaveNextReviewedCategory get saveNextReviewedCategory => _getCached(() => SaveNextReviewedCategory(gameRepository));
  ComputeNumDuplicates get computeNumDuplicates => _getCached(() => ComputeNumDuplicates());
  GetAllRoundDataUpdates get getAllRoundDataUpdates => _getCached(() => GetAllRoundDataUpdates(gameRepository, computeNumDuplicates));
  FinalizeRound get finalizeRound => _getCached(() => FinalizeRound(gameRepository));
  GetPlayers get getPlayers => _getCached(() => GetPlayers(gameRepository));
  SaveAllRoundData get saveAllRoundData => _getCached(() => SaveAllRoundData(gameRepository));
  ComputeWordPoints get computeWordPoints => _getCached(() => ComputeWordPoints());
  GetScoreboard get getScoreboard => _getCached(() => GetScoreboard(gameRepository, computeNumDuplicates, computeWordPoints));

  final Random _random = Random();

  T _getCached<T>(T Function() factory, [String dependencyName = ""]) {
    var key = "${T.toString()}_$dependencyName";
    var cachedValue = _cache[key];
    if (!(cachedValue is T)) {
      cachedValue = factory();
      _cache[key] = cachedValue;
    }
    return cachedValue;
  }

}