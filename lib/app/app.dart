import 'package:findtheword/pages/page_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_bloc.dart';

class FTWApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppBloc()..add(StartInitialisationEvent()),
        child: MaterialApp(
          home: BlocBuilder<AppBloc, AppState>(
            builder: (context, appState) => appState.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (message) => Center(child: Text("ERROR: $message")),
              initialised: (pageState) => PageFactory.fromPageState(pageState)
            ),
          ),
        )
    );
  }
}
