import 'package:findtheword/data/game_repository_impl.dart';
import 'package:findtheword/data/room_repository_impl.dart';
import 'package:findtheword/data/user_id_repository_impl.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/use_case/add_category.dart';
import 'package:findtheword/domain/game/use_case/am_i_game_admin.dart';
import 'package:findtheword/domain/game/use_case/change_settings.dart';
import 'package:findtheword/domain/game/use_case/create_game.dart';
import 'package:findtheword/domain/game/use_case/delete_category.dart';
import 'package:findtheword/domain/game/use_case/get_categories_updates.dart';
import 'package:findtheword/domain/game/use_case/get_default_settings.dart';
import 'package:findtheword/domain/game/use_case/get_game_settings_updates.dart';
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

  GetGameSettingsUpdates get getGameSettingsUpdates => _getCached(() => GetGameSettingsUpdates(gameRepository));

  CreateGame get createGame => _getCached(() => CreateGame(gameRepository, getDefaultSettings));

  AmIGameAdmin get amIGameAdmin => _getCached(() => AmIGameAdmin(userIdRepository, gameRepository));

  SetRoomUnavailable get setRoomUnavailable => _getCached(() => SetRoomUnavailable(roomRepository));

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