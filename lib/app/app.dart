import 'package:findtheword/pages/page_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_bloc.dart';

class FTWApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppBloc()..add(AppEvent.startInitialisation()),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Text("Find the word!")
            ),
            body: BlocBuilder<AppBloc, AppState>(
              builder: (context, appState) => appState.when(
                  initialising: () => Center(child: CircularProgressIndicator()),
                  error: (message) => Center(child: Text("ERROR: $message")),
                  showPage: (pageState) => PageFactory.fromPageState(pageState)
              ),
            ),
          ),
        )
    );
  }
}
