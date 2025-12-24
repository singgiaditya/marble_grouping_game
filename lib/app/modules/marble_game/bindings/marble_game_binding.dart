import 'package:get/get.dart';

import '../controllers/marble_game_controller.dart';

class MarbleGameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarbleGameController>(
      () => MarbleGameController(),
    );
  }
}
