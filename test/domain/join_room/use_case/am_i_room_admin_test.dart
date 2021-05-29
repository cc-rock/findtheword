import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';
import 'package:findtheword/domain/join_room/use_case/am_i_room_admin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserIdRepository extends Mock implements UserIdRepository {}
class MockRoomRepository extends Mock implements RoomRepository {}

void main() {

  late UserIdRepository userIdRepository;
  late RoomRepository roomRepository;
  late AmIRoomAdmin amIRoomAdmin;

  setUp(() {
    userIdRepository = MockUserIdRepository();
    roomRepository = MockRoomRepository();
    amIRoomAdmin = AmIRoomAdmin(userIdRepository, roomRepository);
  });

  test("When the current user id is different from the room admin id, false is returned", () async {
    when(() => userIdRepository.currentUserId).thenAnswer((_) => Future.value("test user id"));
    when(() => roomRepository.getRoomAdminId("roomName")).thenAnswer((_) => Future.value("room admin id"));
    expect(await amIRoomAdmin.invoke("roomName"), Result.success(false));
  });

  test("When the current user id is equal to the room admin id, true is returned", () async {
    when(() => userIdRepository.currentUserId).thenAnswer((_) => Future.value("test user id"));
    when(() => roomRepository.getRoomAdminId("roomName")).thenAnswer((_) => Future.value("test user id"));
    expect(await amIRoomAdmin.invoke("roomName"), Result.success(true));
  });

  test("If an error is thrown by the user repository, it is propagated", () async {
    var error = Exception("test");
    when(() => userIdRepository.currentUserId).thenAnswer((_) => Future.error(error));
    expect(await amIRoomAdmin.invoke("roomName"), Result.error(error));
  });

  test("If an error is thrown by the room repository, it is propagated", () async {
    var error = Exception("test");
    when(() => userIdRepository.currentUserId).thenAnswer((_) => Future.value("test user id"));
    when(() => roomRepository.getRoomAdminId("roomName")).thenAnswer((_) => Future.error(error));
    expect(await amIRoomAdmin.invoke("roomName"), Result.error(error));
  });
}