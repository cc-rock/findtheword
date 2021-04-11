import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/join_room/use_case/am_i_room_admin.dart';
import 'package:findtheword/domain/join_room/use_case/get_room_player_updates.dart';
import 'package:findtheword/domain/join_room/use_case/is_room_complete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wait_for_players_bloc.freezed.dart';
part 'wait_for_players_bloc.g.dart';

@freezed
abstract class WaitForPlayersEvent with _$WaitForPlayersEvent {
  factory WaitForPlayersEvent.start() = Start;
  factory WaitForPlayersEvent.continueClicked() = ContinueClicked;
}

@freezed
abstract class WaitForPlayersState with _$WaitForPlayersState {
  factory WaitForPlayersState(String roomName, bool admin, List<Player> players, bool readyToStart) = _WaitForPlayersState;
  factory WaitForPlayersState.fromJson(Map<String, dynamic> json) => _$WaitForPlayersStateFromJson(json);
}

class WaitForPlayersBloc extends Bloc<WaitForPlayersEvent, WaitForPlayersState> {
  final GetRoomUpdates _getRoomUpdates;
  final AmIRoomAdmin _amIRoomAdmin;
  final IsRoomComplete _isRoomComplete;

  WaitForPlayersBloc(
      WaitForPlayersState initialState, this._getRoomUpdates, this._amIRoomAdmin, this._isRoomComplete
  ): super(initialState) {
    add(WaitForPlayersEvent.start());
  }

  @override
  Stream<WaitForPlayersState> mapEventToState(WaitForPlayersEvent event) async* {
    bool admin = (await _amIRoomAdmin.invoke(state.roomName)).when(
        success: (value) => value,
        error: (error) => false
    );
    if (event is Start) {
      yield* _getRoomUpdates.invoke(state.roomName).map(
              (value) =>
              WaitForPlayersState(state.roomName, admin, value.players, _isRoomComplete.invoke(value))
      );
    } else if (event is ContinueClicked) {
      yield state.copyWith(readyToStart: true);
    }
  }

  factory WaitForPlayersBloc.fromContext(BuildContext context, WaitForPlayersState initialState) {
    Injector injector = context.read();
    return WaitForPlayersBloc(initialState, injector.getRoomPlayerUpdates, injector.amIRoomAdmin, injector.isRoomComplete);
  }

}

