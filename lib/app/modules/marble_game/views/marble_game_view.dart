import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flame/game.dart';
import 'package:marble_grouping_game/app/common/widgets/success_buton.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/core/themes/style/shadow_style.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/marble_flame.dart';

import '../controllers/marble_game_controller.dart';

class GameView extends GetView<MarbleGameController> {
  const GameView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: 24),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: MyColor.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      "Find Theresult of The Division",
                      style: Get.textTheme.titleLarge,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: MyColor.primary,
                        border: Border.all(color: MyColor.secondary, width: 2),
                        boxShadow: [
                          ShadowStyle.defaultShadow.copyWith(
                            color: MyColor.secondary,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Obx(
                          () => Text(
                            "${controller.currentEquation.value.a} ÷ ${controller.currentEquation.value.b}",
                            style: Get.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: Get.width * 0.4,
                      bottom: -20,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: MyColor.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text("=", style: Get.textTheme.headlineLarge),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: -10,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: MyColor.accent,
                          shadowColor: MyColor.secondary,
                          elevation: 4,
                        ),
                        onPressed: controller.generateNewEquation,
                        icon: Icon(Icons.refresh, color: MyColor.secondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(child: GameWidget(game: MarbleFlame())),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: SuccessButon(),
            ),
          ],
        ),
      ),
    );
  }
}
