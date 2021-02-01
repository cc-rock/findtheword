import 'dart:async';

import 'package:findtheword/data/db_wrapper.dart';
import 'package:findtheword/data/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_page_bloc.freezed.dart';

@freezed
abstract class HomePageEvent with _$HomePageEvent {
  const factory HomePageEvent.loadHomePage() = LoadHomePage;
}

@freezed
abstract class HomePageState with _$HomePageState {
  const factory HomePageState.loading() = LoadingHomePage;
  const factory HomePageState.error(String message) = ErrorHomePage;
  const factory HomePageState.homePageData(String userId, List<String> listItems) = HomePageData;
}

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {

  Repository _repository;

  HomePageBloc(this._repository): super(HomePageState.loading());

  @override
  Stream<HomePageState> mapEventToState(HomePageEvent event) {
    try {
      return _repository.stream.map((list) =>
          HomePageData("ciccio", list)
      ).transform(StreamTransformer.fromHandlers(
          handleError: (error, stackTrace, sink) {
            sink.add(HomePageState.error(error.toString()));
          }
      ));
    } catch (e) {
      return Stream.value(HomePageState.error(e.toString()));
    }
  }


}