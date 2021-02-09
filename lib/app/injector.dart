import 'package:findtheword/data/room_repository_impl.dart';
import 'package:findtheword/data/user_id_repository_impl.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';
import 'package:findtheword/domain/join_room/use_case/create_room.dart';
import 'package:findtheword/domain/join_room/use_case/get_room_player_updates.dart';
import 'package:findtheword/domain/join_room/use_case/get_room_status.dart';
import 'package:findtheword/domain/join_room/use_case/join_room.dart';
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

  GetRoomPlayerUpdates get getRoomPlayerUpdates => _getCached(() => GetRoomPlayerUpdates(roomRepository));

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