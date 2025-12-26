import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/core/themes/style/shadow_style.dart';

class ShadowButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final Color bgColor;
  final Color shadowColor;

  const ShadowButton(
    this.label, {
    super.key,
    this.onTap,
    this.bgColor = MyColor.success,
    this.shadowColor = MyColor.darkSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: shadowColor, width: 2),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [ShadowStyle.defaultShadow.copyWith(color: shadowColor)],
        ),
        child: Center(
          child: Text(
            label,
            style: Get.textTheme.titleLarge?.copyWith(
              color: shadowColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
