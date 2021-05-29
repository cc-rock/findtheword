import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';
import 'package:findtheword/domain/join_room/use_case/join_room.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRoomRepository extends Mock implements RoomRepository {}
class MockUserIdRepository extends Mock implements UserIdRepository {}

void main() {

  late JoinRoom joinRoom;
  late RoomRepository roomRepository;
  late UserIdRepository userIdRepository;

  setUp(() {
    userIdRepository = MockUserIdRepository();
    roomRepository = MockRoomRepository();
    joinRoom = JoinRoom(userIdRepository, roomRepository);
    when(() => userIdRepository.currentUserId).thenAnswer((_) => Future.value("test_user_id"));
  });

  test("When there are no errors, the userIdRepository and roomRepository are called and a success result is returned", () async {
    when(() => roomRepository.joinRoom("test_user_id", "Test admin name", "Test room name")).thenAnswer((_) =>
        Future.value(_)
    );
    var result = await joinRoom.invoke("Test admin name", "Test room name");
    verify(() => userIdRepository.currentUserId);
    verify(() => roomRepository.joinRoom("test_user_id", "Test admin name", "Test room name"));
    expect(result, isInstanceOf<ResultSuccess>());
  });

  test("Success scenario with password", () async {
    when(() => roomRepository.joinRoom("test_user_id", "Test admin name", "Test room name", "password")).thenAnswer((_) =>
        Future.value(_)
    );
    var result = await joinRoom.invoke("Test admin name", "Test room name", "password");
    verify(() => userIdRepository.currentUserId);
    verify(() => roomRepository.joinRoom("test_user_id", "Test admin name", "Test room name", "password"));
    expect(result, isInstanceOf<ResultSuccess>());
  });

  test("If the userRepository throws an error, it is correctly propagated.", () async {
    Object error = Exception("TEST ERROR");
    when(() => userIdRepository.currentUserId).thenAnswer((_) => Future.error(error));
    var result = await joinRoom.invoke("Test admin name", "Test room name", "password");
    expect(result, Result.error(error));
  });

  test("If the roomRepository throws an error, it is correctly propagated.", () async {
    Object error = Exception("TEST ERROR");
    when(() => roomRepository.joinRoom("test_user_id", "Test admin name", "Test room name", "password")).thenAnswer((_) =>
        Future.error(error)
    );
    var result = await joinRoom.invoke("Test admin name", "Test room name", "password");
    expect(result, Result.error(error));
  });

}