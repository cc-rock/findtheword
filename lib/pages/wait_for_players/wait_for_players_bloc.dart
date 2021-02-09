import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/join_room/use_case/get_room_player_updates.dart';
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
  factory WaitForPlayersState(String roomName, List<Player> players, bool readyToStart) = _WaitForPlayersState;
  factory WaitForPlayersState.fromJson(Map<String, dynamic> json) => _$WaitForPlayersStateFromJson(json);
}

class WaitForPlayersBloc extends Bloc<WaitForPlayersEvent, WaitForPlayersState> {
  final GetRoomPlayerUpdates _getRoomPlayerUpdates;
  WaitForPlayersBloc(WaitForPlayersState initialState, this._getRoomPlayerUpdates) : super(initialState) {
    add(WaitForPlayersEvent.start());
  }

  @override
  Stream<WaitForPlayersState> mapEventToState(WaitForPlayersEvent event) {
    return event.when(
        start: () => _getRoomPlayerUpdates.invoke(state.roomName).map(
            (value) => WaitForPlayersState(state.roomName, value, false)
        ),
        continueClicked: () => Stream.fromFuture(Future.value(state.copyWith(readyToStart: true)))
    );
  }

  factory WaitForPlayersBloc.fromContext(BuildContext context, WaitForPlayersState initialState) {
    Injector injector = context.read();
    return WaitForPlayersBloc(initialState, injector.getRoomPlayerUpdates);
  }

}

