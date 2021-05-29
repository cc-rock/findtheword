import 'package:bloc_test/bloc_test.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/join_room/use_case/create_room.dart';
import 'package:findtheword/pages/create_room/create_room_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCreateRoom extends Mock implements CreateRoom {}

void main() {

  late CreateRoom createRoom;

  setUp(() {
    createRoom = MockCreateRoom();
  });

  blocTest<CreateRoomBloc, CreateRoomState>("When the checkbox is checked, the password field is enabled",
    build: () => CreateRoomBloc(CreateRoomState.initial("playerName", "roomName"), createRoom),
    act: (bloc) => bloc.add(CreateRoomEvent.checkboxClicked(true)),
    expect: () => [CreateRoomState.initial("playerName", "roomName", requirePasswordChecked: true, passwordFieldEnabled: true)]
  );

  blocTest<CreateRoomBloc, CreateRoomState>("When continue is clicked and the create room request is successful, the loading state and success state are sent",
      build: () {
        when(() => createRoom.invoke("playerName", "roomName")).thenAnswer((_) => Future.value(Result.success("gameId")));
        return CreateRoomBloc(CreateRoomState.initial("playerName", "roomName"), createRoom);
      },
      act: (bloc) => bloc.add(CreateRoomEvent.continueClicked(false, "")),
      expect: () => [CreateRoomState.loading("playerName", "roomName"), CreateRoomState.success("playerName", "roomName", "gameId")]
  );

  blocTest<CreateRoomBloc, CreateRoomState>("When continue is clicked (with password) and the create room request is successful, the loading state and success state are sent",
      build: () {
        when(() => createRoom.invoke("playerName", "roomName", "thePassword")).thenAnswer((_) => Future.value(Result.success("gameId")));
        return CreateRoomBloc(CreateRoomState.initial("playerName", "roomName"), createRoom);
      },
      act: (bloc) => bloc.add(CreateRoomEvent.continueClicked(true, "thePassword")),
      expect: () => [CreateRoomState.loading("playerName", "roomName"), CreateRoomState.success("playerName", "roomName", "gameId")]
  );

  blocTest<CreateRoomBloc, CreateRoomState>("When continue is clicked and the create room request is unsuccessful, the loading state and error state are sent",
      build: () {
        when(() => createRoom.invoke("playerName", "roomName")).thenAnswer((_) => Future.value(Result.error(Exception())));
        return CreateRoomBloc(CreateRoomState.initial("playerName", "roomName"), createRoom);
      },
      act: (bloc) => bloc.add(CreateRoomEvent.continueClicked(false, "")),
      expect: () => [CreateRoomState.loading("playerName", "roomName"), CreateRoomState.error("playerName", "roomName")]
  );

}