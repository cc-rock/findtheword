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
      child: BlocBuilder<WaitForPlayersBloc, WaitForPlayersState>(
        builder: (context, state) {
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Room "${state.roomName}"'),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: state.players.map((player) =>
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${player.name}${player.isAdmin ? ' (admin)' : ''}"),
                            )
                        ).toList(),
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text("Continue"),
                    onPressed: () {
                      //BlocProvider.of<WaitForPlayersBloc>(context).add(WaitForPlayersEvent(passwordController.text));
                    }
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}