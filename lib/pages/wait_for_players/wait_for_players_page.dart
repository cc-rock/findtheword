import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:findtheword/pages/wait_for_players/wait_for_players_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaitForPlayersPage extends StatelessWidget {
  final WaitForPlayersState _initialState;
  WaitForPlayersPage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WaitForPlayersBloc>(
      create: (context) => WaitForPlayersBloc.fromContext(context, _initialState),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<WaitForPlayersBloc, WaitForPlayersState>(
                  builder: (context, state) {
                    return Text('Room "${state.roomName}"');
                  },
                  buildWhen: (previous, next) => previous.roomName != next.roomName,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: BlocBuilder<WaitForPlayersBloc, WaitForPlayersState>(
                    builder: (context, state) {
                      return Column(
                        children: state.players.map((player) =>
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${player.name}${player.isAdmin ? ' (admin)' : ''}"),
                            )
                        ).toList(),
                      );
                    },
                    buildWhen: (previous, next) => previous.players != next.players,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: BlocBuilder<WaitForPlayersBloc, WaitForPlayersState>(
                  builder: (context, state) {
                    return state.admin ? RaisedButton(
                      child: Text("Continue"),
                      onPressed: () {
                        BlocProvider.of<WaitForPlayersBloc>(context).add(WaitForPlayersEvent.continueClicked());
                      }
                    ) : Text("Waiting for the admin to continue.");
                  },
                  buildWhen: (previous, next) => previous.admin != next.admin,
                ),
              ),
              BlocListener<WaitForPlayersBloc, WaitForPlayersState>(
                listener: (context, state) {
                  if (state.readyToStart) {
                    BlocProvider.of<NavigationCubit>(context).goToGameSettings(state.roomName);
                  }
                },
                listenWhen: (previous, next) => next.readyToStart,
              )
            ],
          ),
        ),
      )
    );
  }


}