import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/core/themes/style/shadow_style.dart';
import 'package:marble_grouping_game/app/modules/marble_game/controllers/marble_game_controller.dart';

class EquationCard extends GetView<MarbleGameController> {
  const EquationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalMargin = Get.width * 0.1;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: horizontalMargin,
            right: horizontalMargin,
            bottom: 32,
          ),
          padding: EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: MyColor.primary,
            border: Border.all(color: MyColor.secondary, width: 2),
            boxShadow: [
              ShadowStyle.defaultShadow.copyWith(color: MyColor.secondary),
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
          right: horizontalMargin,
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
        Positioned(
          left: (Get.width * 0.45) - horizontalMargin,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            decoration: BoxDecoration(
              color: MyColor.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "=",
                style: Get.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
