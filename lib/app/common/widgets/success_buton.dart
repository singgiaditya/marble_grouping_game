import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/core/themes/style/shadow_style.dart';

class SuccessButon extends StatelessWidget {
  const SuccessButon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {},
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: MyColor.success,
          border: Border.all(color: MyColor.darkSuccess, width: 2),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            ShadowStyle.defaultShadow.copyWith(
              color: MyColor.darkSuccess,
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Check Answer",
            style: Get.textTheme.titleLarge?.copyWith(
              color: MyColor.darkSuccess,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
