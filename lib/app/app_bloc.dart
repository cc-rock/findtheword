import 'package:findtheword/pages/home/home_page_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'injector.dart';

part 'app_bloc.freezed.dart';

@freezed
abstract class AppEvent with _$AppEvent {
  const factory AppEvent.startInitialisation() = AppEventStartInitialisation;
  const factory AppEvent.goToPage(Object pageState) = AppEventGoToPage;
}

@freezed
abstract class AppState with _$AppState {
  const factory AppState.initialising() = AppStateInitialising;
  const factory AppState.showPage(@nullable Object pageState) = AppStateInitialised;
  const factory AppState.error(String message) = AppStateError;
}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initialising());

  Injector injector;

  Future<AppState> _initialise() async {
    try {
      await Firebase.initializeApp();
      await FirebaseAuth.instance.signInAnonymously();
      injector = Injector();
      return AppState.showPage(HomePageState("", "", false));
    } catch (error) {
      return AppState.error(error.toString());
    }
  }

  @override
  Stream<AppState> mapEventToState(AppEvent event) {
    return Stream.fromFuture(_initialise());
  }
}