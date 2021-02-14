import 'dart:ffi';

import 'package:bloc_test/bloc_test.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/join_room/room_status.dart';
import 'package:findtheword/domain/join_room/use_case/get_room_status.dart';
import 'package:findtheword/domain/join_room/use_case/join_room.dart';
import 'package:findtheword/pages/join_room/join_room_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetRoomStatus extends Mock implements GetRoomStatus {}
class MockJoinRoom extends Mock implements JoinRoom {}

const String playerName = "Test Player";
const String roomName = "Test Room";

void main() {

  GetRoomStatus getRoomStatus;
  JoinRoom joinRoom;

  setUp(() {
    getRoomStatus = MockGetRoomStatus();
    joinRoom = MockJoinRoom();
  });

  JoinRoomBloc buildBloc(RoomStatus roomStatus, [String password]) {
    when(getRoomStatus.invoke(roomName)).thenAnswer((_) => Future.value(Result.success(roomStatus)));
    return JoinRoomBloc(
        getRoomStatus, joinRoom, JoinRoomState.loading(JoinRoomRequest(playerName, roomName, password))
    );
  }

  blocTest("When the room status is non existent, navigation is triggered to the create room page",
    build: () => buildBloc(RoomStatus.nonExistent),
    expect: [
      JoinRoomState.loading(JoinRoomRequest(playerName, roomName)),
      JoinRoomState.navigate(JoinRoomRequest(playerName, roomName), JoinRoomNavigationAction.goToCreateRoom),
    ],
    verify: (_) {
      verify(getRoomStatus.invoke(roomName));
    }
  );

  blocTest("When the room status is available with password and no password is provided, navigation is triggered to the ask password page",
      build: () => buildBloc(RoomStatus.availableWithPassword),
      expect: [
        JoinRoomState.loading(JoinRoomRequest(playerName, roomName)),
        JoinRoomState.navigate(JoinRoomRequest(playerName, roomName), JoinRoomNavigationAction.goToAskPassword),
      ],
      verify: (_) {
        verify(getRoomStatus.invoke(roomName));
      }
  );

  blocTest("When the room status is unavailable, the room unavailable status is returned",
      build: () => buildBloc(RoomStatus.unavailable),
      expect: [
        JoinRoomState.loading(JoinRoomRequest(playerName, roomName)),
        JoinRoomState.roomUnavailable(JoinRoomRequest(playerName, roomName)),
      ],
      verify: (_) {
        verify(getRoomStatus.invoke(roomName));
      }
  );

  blocTest("If an error is returned by getRoomStatus, the error state is returned",
      build: () {
        JoinRoomBloc bloc = buildBloc(RoomStatus.availableWithPassword);
        when(getRoomStatus.invoke(roomName)).thenAnswer((_) => Future.value(Result.error(Exception())));
        return bloc;
      },
      expect: [
        JoinRoomState.loading(JoinRoomRequest(playerName, roomName)),
        JoinRoomState.error(JoinRoomRequest(playerName, roomName)),
      ],
      verify: (_) {
        verify(getRoomStatus.invoke(roomName));
      }
  );

  blocTest("When the room status is available and joinRoom is successful, navigation is triggered to the wait for players page",
      build: () {
        when(joinRoom.invoke(playerName, roomName)).thenAnswer((realInvocation) => Future.value(Result.success("")));
        return buildBloc(RoomStatus.available);
      },
      expect: [
        JoinRoomState.loading(JoinRoomRequest(playerName, roomName)),
        JoinRoomState.navigate(JoinRoomRequest(playerName, roomName), JoinRoomNavigationAction.goToWaitForPlayers),
      ],
      verify: (_) {
        verify(getRoomStatus.invoke(roomName));
        verify(joinRoom.invoke(playerName, roomName));
      }
  );

  blocTest("When the room status is available and joinRoom returns error, the error state is returned",
      build: () {
        when(joinRoom.invoke(playerName, roomName)).thenAnswer((realInvocation) => Future.value(Result.error(Exception())));
        return buildBloc(RoomStatus.available);
      },
      expect: [
        JoinRoomState.loading(JoinRoomRequest(playerName, roomName)),
        JoinRoomState.error(JoinRoomRequest(playerName, roomName)),
      ],
      verify: (_) {
        verify(getRoomStatus.invoke(roomName));
        verify(joinRoom.invoke(playerName, roomName));
      }
  );

  blocTest("When the room status is available with password, a password is provided and joinRoom is successful, navigation is triggered to the wait for players page",
      build: () {
        when(joinRoom.invoke(playerName, roomName, "aPassword")).thenAnswer((realInvocation) => Future.value(Result.success("")));
        return buildBloc(RoomStatus.availableWithPassword, "aPassword");
      },
      expect: [
        JoinRoomState.loading(JoinRoomRequest(playerName, roomName, "aPassword")),
        JoinRoomState.navigate(JoinRoomRequest(playerName, roomName, "aPassword"), JoinRoomNavigationAction.goToWaitForPlayers),
      ],
      verify: (_) {
        verify(getRoomStatus.invoke(roomName));
        verify(joinRoom.invoke(playerName, roomName, "aPassword"));
      }
  );

  blocTest("When the initial state is 'error', the request is not fired",
      build: () {
        return JoinRoomBloc(getRoomStatus, joinRoom, JoinRoomState.error(JoinRoomRequest(playerName, roomName)));
      },
      expect: [],
      verify: (_) {
        verifyNever(getRoomStatus.invoke(roomName));
        verifyNever(joinRoom.invoke(playerName, roomName));
      }
  );

  blocTest("When the initial state is 'room unavailable', the request is not fired",
      build: () {
        return JoinRoomBloc(getRoomStatus, joinRoom, JoinRoomState.roomUnavailable(JoinRoomRequest(playerName, roomName)));
      },
      expect: [],
      verify: (_) {
        verifyNever(getRoomStatus.invoke(roomName));
        verifyNever(joinRoom.invoke(playerName, roomName));
      }
  );

  blocTest("When 'start again' is pressed, navigation is triggered to the home page",
      build: () {
        return JoinRoomBloc(getRoomStatus, joinRoom, JoinRoomState.error(JoinRoomRequest(playerName, roomName)));
      },
      act: (bloc) => bloc.add(JoinRoomEvent.startAgainPressed()),
      expect: [JoinRoomStateNavigate(JoinRoomRequest(playerName, roomName), JoinRoomNavigationAction.goToHomePage)],
      verify: (_) {
        verifyNever(getRoomStatus.invoke(roomName));
        verifyNever(joinRoom.invoke(playerName, roomName));
      }
  );

  blocTest("When 'try another password' is pressed, navigation is triggered to ask password page",
      build: () {
        return JoinRoomBloc(getRoomStatus, joinRoom, JoinRoomState.error(JoinRoomRequest(playerName, roomName)));
      },
      act: (bloc) => bloc.add(JoinRoomEvent.tryOtherPasswordPressed()),
      expect: [JoinRoomStateNavigate(JoinRoomRequest(playerName, roomName), JoinRoomNavigationAction.goToAskPassword
      )],
      verify: (_) {
        verifyNever(getRoomStatus.invoke(roomName));
        verifyNever(joinRoom.invoke(playerName, roomName));
      }
  );


}