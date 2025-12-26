import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flame/game.dart';
import 'package:marble_grouping_game/app/common/widgets/shadow_button.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/marble_flame.dart';
import 'package:marble_grouping_game/app/modules/marble_game/widgets/equation_card.dart';

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
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                EquationCard(),
              ],
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final game = MarbleFlame();
                  controller.game = game;
                  // Initialize game after assignment
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.initializeGame();
                  });
                  return GameWidget(game: game);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ShadowButton(
                "Check Answer",
                onTap: controller.checkAnswer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
