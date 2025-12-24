import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';

class Marble extends CircleComponent {
  Marble({super.position, super.radius = 10}) {
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      center.toOffset(),
      radius + 1,
      Paint()
        ..color = MyColor.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center.toOffset(),
      radius,
      Paint()..color = MyColor.primary,
    );
  }
}
