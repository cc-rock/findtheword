import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:findtheword/pages/home/home_page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {

  final HomePageState _initialState;

  HomePage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomePageBloc>(
      create: (context) => HomePageBloc(_initialState),
      child: Builder(
        builder: (context) {
          HomePageBloc bloc = BlocProvider.of(context);
          TextEditingController playerNameController = TextEditingController(text: _initialState.playerName);
          TextEditingController roomNameController = TextEditingController(text: _initialState.roomName);
          void Function() listener = () {
            bloc.add(HomePageEvent.textChanged(playerNameController.text, roomNameController.text));
          };
          playerNameController.addListener(listener);
          roomNameController.addListener(listener);
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Player Name',
                        ),
                      controller: playerNameController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Room Name',
                      ),
                      controller: roomNameController,
                    ),
                  ),
                  Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BlocBuilder<HomePageBloc, HomePageState>(
                        builder: (context, state) => ElevatedButton(
                            onPressed: state.joinButtonEnabled ? () => bloc.add(HomePageEvent.joinPressed()) : null,
                            child: Text("Join"),
                        ),
                      buildWhen: (previous, next) => previous.joinButtonEnabled != next.joinButtonEnabled,
                    ),
                  ),
                  BlocListener<HomePageBloc, HomePageState>(
                      listener: (context, state) {
                        if (state.action == HomePageAction.GO_TO_NEXT_PAGE) {
                          BlocProvider.of<NavigationCubit>(context).goToJoinRoom(
                              state.playerName, state.roomName
                          );
                        }
                      },
                    listenWhen: (previous, next) => next.action != null,
                    child: Container(),
                  )
                ],
              ),
            ),
          );
        },
      )
    );
  }

}