import 'package:findtheword/pages/ask_password/ask_password_bloc.dart';
import 'package:findtheword/pages/create_room/create_room_bloc.dart';
import 'package:findtheword/pages/home/home_page_bloc.dart';
import 'package:findtheword/pages/join_room/join_room_bloc.dart';
import 'package:findtheword/pages/wait_for_players/wait_for_players_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationState {
  final Object pageState;
  NavigationState(this.pageState);
}

class NavigationCubit extends Cubit<NavigationState> {

  NavigationCubit(Object initialPageState) : super(NavigationState(initialPageState));

  void goToHomePage(String playerName, String roomName) {
    emit(NavigationState(HomePageState(playerName, roomName, (roomName.isNotEmpty && playerName.isNotEmpty))));
  }

  void goToJoinRoom(String playerName, String roomName, [String password]) {
    emit(NavigationState(JoinRoomState.loading(JoinRoomRequest(playerName, roomName, password))));
  }

  void goToCreateRoom(String playerName, String roomName) {
    emit(NavigationState(CreateRoomState.initial(playerName, roomName)));
  }

  void goToAskPassword(String playerName, String roomName) {
    emit(NavigationState(AskPasswordState(playerName, roomName)));
  }

  void goToWaitForPlayers(String roomName) {
    emit(NavigationState(WaitForPlayersState(roomName, [], false)));
  }

}