import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'injector.dart';

part 'app_bloc.freezed.dart';

class StartInitialisationEvent {}

@freezed
abstract class AppState with _$AppState {
  const factory AppState.loading() = AppStateLoading;
  const factory AppState.initialised(@nullable Object pageState) = AppStateInitialised;
  const factory AppState.error(String message) = AppStateError;
}

class AppBloc extends Bloc<StartInitialisationEvent, AppState> {
  AppBloc() : super(AppState.loading());

  Injector injector;

  Future<AppState> _initialise() async {
    try {
      await Firebase.initializeApp();
      await FirebaseAuth.instance.signInAnonymously();
      injector = Injector();
      return AppState.initialised(null);
    } catch (error) {
      return AppState.error(error.toString());
    }
  }

  @override
  Stream<AppState> mapEventToState(StartInitialisationEvent event) async* {
    yield await _initialise();
  }
}