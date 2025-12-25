import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';

class Marble extends CircleComponent {
  Marble({super.position, super.radius = 10, super.anchor = Anchor.center});

  @override
  bool get debugMode => true; // Temporarily disable to check render alignment

  @override
  Future<void> onLoad() async {
    super.onLoad();
    paintLayers = [
      Paint()
        ..color = MyColor.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
      Paint()
        ..color = MyColor.primary
        ..style = PaintingStyle.fill,
    ];
  }
}
