import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:findtheword/pages/game/game_settings/game_settings_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameSettingsPage extends StatelessWidget {

  final GameSettingsState _initialState;

  GameSettingsPage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameSettingsBloc>(
        create: (context) => GameSettingsBloc.fromContext(context, _initialState),
        child: Center(
          child: Container(
              constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Game Settings",),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Categories"),
                  ),
                  BlocBuilder<GameSettingsBloc, GameSettingsState>(
                      builder: (context, state) => Container(
                        height: 200,
                        child: ListView(
                          children: [
                            ...state.categories.map((category) => Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                              child: Text(category),
                            )),
                            if (state.admin) Container(
                              width: 30,
                              child: ElevatedButton(
                                child: Text("+"),
                                onPressed: () async {
                                  final category = await _showAddCategoryDialog(context);
                                  if (category != null && category.isNotEmpty) {
                                    BlocProvider.of<GameSettingsBloc>(context).add(GameSettingsEvent.addedCategory(category));
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                    ),
                    buildWhen: (prev, next) => prev.admin != next.admin || prev.categories != next.categories,
                  ),
                  Builder(
                    builder: (context) {
                      TextEditingController controller = TextEditingController();
                      controller.addListener(() {
                        BlocProvider.of<GameSettingsBloc>(context).add(GameSettingsEvent.durationChanged(controller.text));
                      });
                      return BlocBuilder<GameSettingsBloc, GameSettingsState>(
                      builder: (context, state) {
                        if (controller.text.isEmpty && state.durationText.isNotEmpty) {
                          controller.text = state.durationText;
                        }
                        if (state.admin) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Round duration (mm:ss)',
                                    errorText: state.durationIsValid ? null : "Check duration format"
                                )
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Round duration: ${state.durationText}")
                          );
                        }
                      },
                      buildWhen: (prev, next) => prev.durationText != next.durationText || prev.durationIsValid != next.durationIsValid,
                    );
                  }),
                  BlocBuilder<GameSettingsBloc, GameSettingsState>(
                    builder: (context, state) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: state.finishWhenFirstFinishes,
                            onChanged: state.admin ? (value) {
                              BlocProvider.of<GameSettingsBloc>(context).add(GameSettingsEvent.finishModeCheckboxClicked(value ?? false));
                            } : null
                          ),
                          Text("Finish when first player finishes")
                        ],
                      ),
                    ),
                    buildWhen: (prev, next) => prev.finishWhenFirstFinishes != next.finishWhenFirstFinishes,
                  ),
                  Expanded(child: Container()),
                  BlocBuilder<GameSettingsBloc, GameSettingsState>(
                    builder: (context, state) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Text("Start"),
                        onPressed: state.startButtonEnabled ? () {
                          BlocProvider.of<GameSettingsBloc>(context).add(GameSettingsEvent.startClicked());
                        } : null,
                      ),
                    ),
                    buildWhen: (prev, next) => prev.startButtonEnabled != next.startButtonEnabled
                  ),
                  BlocListener<GameSettingsBloc, GameSettingsState>(
                    listener: (context, state) {
                      BlocProvider.of<NavigationCubit>(context).goToPlayRound(state.gameId);
                    },
                    child: Container(),
                    listenWhen: (prev, next) => next.goToFirstRound,
                  )
                ],
              )
          ),
        )
    );
  }

  Future<String?> _showAddCategoryDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Category name',
            ),
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

}