import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/join_room/use_case/create_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_room_bloc.freezed.dart';
part 'create_room_bloc.g.dart';

@freezed
abstract class CreateRoomEvent with _$CreateRoomEvent {
  factory CreateRoomEvent.checkboxClicked(bool checked) = CheckboxClicked;
  factory CreateRoomEvent.continueClicked(bool requirePasswordChecked, String password) = ContinueClicked;
}

@freezed
abstract class CreateRoomState with _$CreateRoomState {
  factory CreateRoomState.initial(
      String playerName, String roomName, {@Default(false) bool requirePasswordChecked, @Default(false) bool passwordFieldEnabled}
      ) = CreateRoomStateInitial;
  factory CreateRoomState.loading(String playerName, String roomName) = CreateRoomStateLoading;
  factory CreateRoomState.success(String playerName, String roomName, String gameId) = CreateRoomStateSuccess;
  factory CreateRoomState.error(String playerName, String roomName) = CreateRoomStateError;
  factory CreateRoomState.fromJson(Map<String, dynamic> json) => _$CreateRoomStateFromJson(json);
}

class CreateRoomBloc extends Bloc<CreateRoomEvent, CreateRoomState> {
  final CreateRoom _createRoom;

  CreateRoomBloc(CreateRoomState initialState, this._createRoom) : super(initialState);

  @override
  Stream<CreateRoomState> mapEventToState(CreateRoomEvent event) {
    return event.when(
        checkboxClicked: (checked) async* {
          yield CreateRoomState.initial(
              state.playerName, state.roomName, requirePasswordChecked: checked, passwordFieldEnabled: checked
          );
        },
        continueClicked: (requirePasswordChecked, password) async* {
          yield CreateRoomState.loading(state.playerName, state.roomName);
          var result = await _createRoom.invoke(state.playerName, state.roomName, requirePasswordChecked ? password : null);
          if (result is ResultSuccess) {
            yield CreateRoomState.success(state.playerName, state.roomName, (result as ResultSuccess).value);
          } else {
            yield CreateRoomState.error(state.playerName, state.roomName);
          }
        }
    );
  }

  factory CreateRoomBloc.fromContext(BuildContext context, CreateRoomState initialState) {
    Injector injector = context.read();
    return CreateRoomBloc(initialState, injector.createRoom);
  }

}