import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/join_room/room.dart';
import 'package:findtheword/domain/join_room/use_case/get_room_status.dart';
import 'package:findtheword/domain/join_room/use_case/join_room.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'join_room_bloc.freezed.dart';
part 'join_room_bloc.g.dart';

@freezed
class JoinRoomRequest with _$JoinRoomRequest {
  factory JoinRoomRequest(String playerName, String roomName, [String? password]) = _JoinRoomRequest;
  factory JoinRoomRequest.fromJson(Map<String, dynamic> json) => _$JoinRoomRequestFromJson(json);
}

enum JoinRoomNavigationAction {
  goToAskPassword,
  goToCreateRoom,
  goToHomePage,
  goToWaitForPlayers
}

@freezed
class JoinRoomState with _$JoinRoomState {
  factory JoinRoomState.loading(JoinRoomRequest request) = JoinRoomStateLoading;
  factory JoinRoomState.roomUnavailable(JoinRoomRequest request) = JoinRoomStateUnavailable;
  factory JoinRoomState.error(JoinRoomRequest request) = JoinRoomStateError;
  factory JoinRoomState.navigate(JoinRoomRequest request, JoinRoomNavigationAction action) = JoinRoomStateNavigate;
  factory JoinRoomState.fromJson(Map<String, dynamic> json) => _$JoinRoomStateFromJson(json);
}

@freezed
class JoinRoomEvent with _$JoinRoomEvent {
  factory JoinRoomEvent.sendRequest() = SendRequest;
  factory JoinRoomEvent.startAgainPressed() = StartAgainPressed;
  factory JoinRoomEvent.tryOtherPasswordPressed() = TryOtherPasswordPressed;
}

class JoinRoomBloc extends Bloc<JoinRoomEvent, JoinRoomState> {

  GetRoomStatus _getRoomStatus;
  JoinRoom _joinRoom;

  JoinRoomBloc(this._getRoomStatus, this._joinRoom, JoinRoomState initialState): super(initialState) {
    if (initialState is JoinRoomStateLoading) {
      add(JoinRoomEvent.sendRequest());
    }
  }

  @override
  Stream<JoinRoomState> mapEventToState(JoinRoomEvent event) {
    return event.when(
        sendRequest: () => _sendJoinRequest(state.request),
        startAgainPressed: () => Stream.fromFuture(
            Future.value(JoinRoomState.navigate(state.request, JoinRoomNavigationAction.goToHomePage))
        ),
        tryOtherPasswordPressed: () => Stream.fromFuture(
            Future.value(JoinRoomState.navigate(state.request, JoinRoomNavigationAction.goToAskPassword))
        ),
    );
  }

  Stream<JoinRoomState> _sendJoinRequest(JoinRoomRequest request) async* {
    yield JoinRoomState.loading(request);
    var statusResult = await _getRoomStatus.invoke(request.roomName);
    if (statusResult is ResultError) {
      yield JoinRoomState.error(request);
      return;
    }
    switch((statusResult as ResultSuccess).value) {
      case RoomStatus.nonExistent:
        yield JoinRoomState.navigate(
            request, JoinRoomNavigationAction.goToCreateRoom);
        return;
      case RoomStatus.unavailable:
        yield JoinRoomState.roomUnavailable(request);
        return;
      case RoomStatus.availableWithPassword:
        if (request.password == null) {
          yield JoinRoomState.navigate(
              request, JoinRoomNavigationAction.goToAskPassword);
          return;
        }
        break;
      case RoomStatus.available:
    }
    yield await _joinRoom.invoke(request.playerName, request.roomName, request.password).then(
            (value) => value.when(
                success: (_) => JoinRoomState.navigate(request, JoinRoomNavigationAction.goToWaitForPlayers),
                error: (error) => JoinRoomState.error(request)
            )
    );
  }

  factory JoinRoomBloc.fromContext(BuildContext context, JoinRoomState initialState) {
    Injector injector = context.read();
    return JoinRoomBloc(injector.getRoomStatus, injector.joinRoom, initialState);
  }

}