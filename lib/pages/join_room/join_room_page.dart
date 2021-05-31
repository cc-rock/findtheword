import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indent/indent.dart';

import 'join_room_bloc.dart';

class JoinRoomPage extends StatelessWidget {
  final JoinRoomState _initialState;
  JoinRoomPage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinRoomBloc>(
      create: (context) => JoinRoomBloc.fromContext(context, _initialState),
      child: Center(
        child: Container(
          constraints:  BoxConstraints(maxWidth: 400, maxHeight: 700),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<JoinRoomBloc, JoinRoomState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      loading: (_) => Center(child: CircularProgressIndicator()),
                      roomUnavailable: (request) => _showMessage(
                        context,
                        'The room "${request.roomName}" is not available at the moment. Try another room.',
                        false
                      ),
                      error: (request) => _showMessage(
                        context,
                          '''
                          The room "${request.roomName}" could not be joined, an error has occurred.
                          If you entered a password, it might not be the correct one.
                          '''.unindent(),
                          request.password != null
                      ),
                      orElse: () => Container()
                    );
                  },
                  buildWhen: (oldState, newState) => (newState is JoinRoomStateLoading)
                      || (newState is JoinRoomStateUnavailable)
                      || (newState is JoinRoomStateError),
                ),
              ),
              BlocListener<JoinRoomBloc, JoinRoomState>(
                listener: (context, state) {
                  state.maybeWhen(
                    navigate: (request, action) {
                      switch(action) {
                        case JoinRoomNavigationAction.goToHomePage:
                          BlocProvider.of<NavigationCubit>(context).goToHomePage(state.request.playerName, state.request.roomName);
                          break;
                        case JoinRoomNavigationAction.goToCreateRoom:
                          BlocProvider.of<NavigationCubit>(context).goToCreateRoom(state.request.playerName, state.request.roomName);
                          break;
                        case JoinRoomNavigationAction.goToAskPassword:
                          BlocProvider.of<NavigationCubit>(context).goToAskPassword(state.request.playerName, state.request.roomName);
                          break;
                        case JoinRoomNavigationAction.goToWaitForPlayers:
                          BlocProvider.of<NavigationCubit>(context).goToWaitForPlayers(state.request.roomName);
                          break;
                      }
                    },
                    orElse: () {}
                  );
                },
                listenWhen: (oldState, newState) => newState is JoinRoomStateNavigate,
                child: Container(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _showMessage(BuildContext context, String message, bool showNewPassword) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(message),
      ),
      Expanded(child: Container()),
      showNewPassword ? Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ElevatedButton(
          child: Text("Try another password"),
          onPressed: () => {
            BlocProvider.of<JoinRoomBloc>(context).add(JoinRoomEvent.tryOtherPasswordPressed())
          }
        ),
      ) : Container(),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          child: Text("Start again"),
            onPressed: () => {
              BlocProvider.of<JoinRoomBloc>(context).add(JoinRoomEvent.startAgainPressed())
            }
        ),
      )
    ],
  );

}