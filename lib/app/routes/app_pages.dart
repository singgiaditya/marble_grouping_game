import 'package:get/get.dart';

import '../modules/marble_game/bindings/marble_game_binding.dart';
import '../modules/marble_game/views/marble_game_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.GAME;

  static final routes = [
    GetPage(
      name: _Paths.GAME,
      page: () => const GameView(),
      binding: MarbleGameBinding(),
    ),
  ];
}
