import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';

class SubmitArea extends PositionComponent {
  final Color bgColor;
  final Color shadowColor;
  final double radius;

  SubmitArea({this.bgColor = MyColor.area1, this.shadowColor = MyColor.area1Shadow, this.radius = 8.0});

  @override
  // TODO: implement debugMode
  bool get debugMode => false;

  late final Paint _shadowPaint;

  late final Paint _rectPaint;

  @override
  void render(Canvas canvas) {
    // Draw shadow
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 4, size.x, size.y),
      Radius.circular(radius),
    );
    canvas.drawRRect(shadowRect, _shadowPaint);

    // Draw main rectangle
    final mainRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(radius),
    );
    canvas.drawRRect(mainRect, _rectPaint);
  }

  @override
  void onLoad() {
    _shadowPaint = Paint()
    ..color = shadowColor
    ..style = PaintingStyle.fill;

    _rectPaint = Paint()
    ..color = bgColor
    ..style = PaintingStyle.fill;
    size = Vector2(size.x, size.y);
  }
}