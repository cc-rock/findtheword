import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';
import 'package:findtheword/domain/join_room/room.dart';
import 'package:findtheword/domain/join_room/use_case/get_room_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

void main() {

  late GetRoomStatus getRoomStatus;
  late RoomRepository roomRepository;

  setUp(() {
    roomRepository = MockRoomRepository();
    getRoomStatus = GetRoomStatus(roomRepository);
  });

  test("When there are no errors, the roomRepository is called and a success result is returned", () async {
    when(() => roomRepository.getRoomStatus("test room")).thenAnswer((_) => Future.value(RoomStatus.available));
    var result = await getRoomStatus.invoke("test room");
    expect(result, Result.success(RoomStatus.available));
  });

  test("Errors returned by the room repository are propagated", () async {
    var error = Exception("Test exception");
    when(() => roomRepository.getRoomStatus("test room")).thenAnswer((_) => Future.error(error));
    var result = await getRoomStatus.invoke("test room");
    expect(result, Result.error(error));
  });

}