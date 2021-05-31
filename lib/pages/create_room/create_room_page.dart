import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indent/indent.dart';

import 'create_room_bloc.dart';

class CreateRoomPage extends StatelessWidget {
  final CreateRoomState _initialState;
  CreateRoomPage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateRoomBloc>(
      create: (context) => CreateRoomBloc.fromContext(context, _initialState),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
          child: BlocBuilder<CreateRoomBloc, CreateRoomState>(
            builder: (context, state) {
              if (state is CreateRoomStateInitial) {
                TextEditingController passwordController = TextEditingController();
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('''
                    The room "${state.roomName} does not exist yet.
                    Press "Continue" to create it, you will be the game administrator.
                    '''.unindent()),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: CheckboxListTile(
                        title: Text("Require password"),
                        value: state.requirePasswordChecked,
                        onChanged: (newValue) {
                          BlocProvider.of<CreateRoomBloc>(context).add(CreateRoomEvent.checkboxClicked(newValue ?? false));
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: state.passwordFieldEnabled ? TextField(
                        controller: passwordController,
                      ) : FocusScope(
                        node: FocusScopeNode(),
                          child: TextField(
                            controller: passwordController,
                            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                          )
                      ),
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ElevatedButton(
                          child: Text("Continue"),
                          onPressed: () {
                            BlocProvider.of<CreateRoomBloc>(context).add(CreateRoomEvent.continueClicked(state.requirePasswordChecked, passwordController.text));
                          }
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ElevatedButton(
                          child: Text("Start again"),
                          onPressed: () {
                            BlocProvider.of<NavigationCubit>(context).goToHomePage(state.playerName, state.roomName);
                          }
                      ),
                    )
                  ],
                );
              } else if (state is CreateRoomStateSuccess) {
                BlocProvider.of<NavigationCubit>(context).goToWaitForPlayers(state.roomName);
                return Container();
              } else if (state is CreateRoomStateError) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('''
                        The room "${state.roomName} couldn't be created, an error has occurred.
                        Please try again later.
                    '''.unindent()),
                    ),
                    Expanded(child: Container()),
                    ElevatedButton(
                        child: Text("Start again"),
                        onPressed: () {
                          BlocProvider.of<NavigationCubit>(context).goToHomePage(state.playerName, state.roomName);
                        }
                    )
                  ],
                );
              } else if (state is CreateRoomStateLoading) {
                return Center(child: CircularProgressIndicator());
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }


}