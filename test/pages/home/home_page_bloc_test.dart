import 'package:bloc_test/bloc_test.dart';
import 'package:findtheword/pages/home/home_page_bloc.dart';

void main() {

  blocTest<HomePageBloc, HomePageState>("If player name changes but room name remains empty, the button is not enabled, an no navigation happens",
    build: () => HomePageBloc(HomePageState("", "", false)),
    act: (bloc) => bloc.add(HomePageEvent.textChanged("playerName", "")),
    expect: () => [HomePageState("playerName", "", false)]
  );

  blocTest<HomePageBloc, HomePageState>("If room name changes but player name remains empty, the button is not enabled, an no navigation happens",
      build: () => HomePageBloc(HomePageState("", "", false)),
      act: (bloc) => bloc.add(HomePageEvent.textChanged("", "roomName")),
      expect: () => [HomePageState("", "roomName", false)]
  );

  blocTest<HomePageBloc, HomePageState>("If both player name and room name are not empty, the button is enabled",
      build: () => HomePageBloc(HomePageState("", "", false)),
      act: (bloc) => bloc.add(HomePageEvent.textChanged("playerName", "roomName")),
      expect: () => [HomePageState("playerName", "roomName", true)]
  );

  blocTest<HomePageBloc, HomePageState>("If one of the two fields goes back to empty, the button is disabled",
      build: () => HomePageBloc(HomePageState("playerName", "roomName", true)),
      act: (bloc) => bloc.add(HomePageEvent.textChanged("", "roomName")),
      expect: () => [HomePageState("", "roomName", false)]
  );

  blocTest<HomePageBloc, HomePageState>("If the continue button is pressed,navigation is triggered to the next page",
      build: () => HomePageBloc(HomePageState("playerName", "roomName", true)),
      act: (bloc) => bloc.add(HomePageEvent.joinPressed()),
      expect: () => [HomePageState("playerName", "roomName", true, action: HomePageAction.GO_TO_NEXT_PAGE)]
  );

}