import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';

class SubmitArea extends PositionComponent {
  final Color bgColor;
  final Color shadowColor;
  final double radius;

  // Group management
  MarbleGroup? assignedGroup;
  bool isHighlighted = false;

  SubmitArea({
    this.bgColor = MyColor.area1,
    this.shadowColor = MyColor.area1Shadow,
    this.radius = 8.0,
  });

  @override
  bool get debugMode => false;

  late final Paint _shadowPaint;
  late final Paint _rectPaint;
  late final Paint _highlightPaint;

  /// Get the snap position (center of the submit area)
  Vector2 get snapPosition => position + size / 2;

  /// Check if a group's bounding box overlaps with this area
  bool containsGroup(MarbleGroup group) {
    final groupBounds = group.getBoundingBox();
    final areaBounds = toRect();

    return areaBounds.overlaps(groupBounds);
  }

  /// Assign a group to this submit area
  void assignGroup(MarbleGroup group) {
    // Remove from previous area if any
    if (assignedGroup != null && assignedGroup != group) {
      assignedGroup!.assignedArea = null;
    }

    assignedGroup = group;
    group.assignedArea = this;
    isHighlighted = false;
  }

  /// Remove the assigned group
  void removeGroup() {
    if (assignedGroup != null) {
      assignedGroup!.assignedArea = null;
      assignedGroup = null;
    }
  }

  /// Highlight the area (visual feedback when group is hovering)
  void highlightArea(bool highlight) {
    isHighlighted = highlight;
  }

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

    // Draw highlight if active
    if (isHighlighted) {
      canvas.drawRRect(mainRect, _highlightPaint);
    }
  }

  @override
  void onLoad() {
    _shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    _rectPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    _highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    size = Vector2(size.x, size.y);
  }
}
