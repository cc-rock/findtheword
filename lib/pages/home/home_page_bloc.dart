import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_page_bloc.freezed.dart';

@freezed
abstract class HomePageEvent with _$HomePageEvent {
  const factory HomePageEvent.textChanged(String playerName, String roomName) = TextChanged;
  const factory HomePageEvent.joinPressed() = JoinPressed;
}

enum HomePageAction { GO_TO_NEXT_PAGE }

@freezed
abstract class HomePageState with _$HomePageState {
  factory HomePageState(
      String playerName,
      String roomName,
      bool joinButtonEnabled,
      {HomePageAction action}
  ) = _HomePageAction;
}

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {

  HomePageBloc(HomePageState initialState): super(initialState);

  @override
  Stream<HomePageState> mapEventToState(HomePageEvent event) async* {
    yield event.when(
        textChanged: (playerName, roomName) => HomePageState(
            playerName,
            roomName,
            playerName.isNotEmpty && roomName.isNotEmpty
        ),
      joinPressed: () => state.copyWith(action: HomePageAction.GO_TO_NEXT_PAGE)
    );
  }


}