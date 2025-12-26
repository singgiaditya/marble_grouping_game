import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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
  bool get debugMode => true;

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

  /// Submit a group to this area
  /// Returns true if successful, false if area is already full
  bool submitGroup(MarbleGroup group) {
    // Only allow one group per submit area
    if (assignedGroup != null && assignedGroup != group) {
      // Area is full - show error effect
      _showErrorEffect();
      return false;
    }

    assignedGroup = group;
    group.assignedArea = this;
    group.isSubmitted = true;
    isHighlighted = false;

    // Hide connection lines
    group.hideConnectionLines();

    // Change marble colors to match submit area
    group.changeMarbleColors(bgColor);

    // Arrange marbles in rows at right-center of submit area
    arrangeMarblesInRows(group);

    return true;
  }

  /// Show error effect when trying to submit to full area
  void _showErrorEffect() {
    // Shake animation
    add(
      SequenceEffect([
        MoveEffect.by(Vector2(5, 0), EffectController(duration: 0.05)),
        MoveEffect.by(Vector2(-10, 0), EffectController(duration: 0.1)),
        MoveEffect.by(Vector2(10, 0), EffectController(duration: 0.1)),
        MoveEffect.by(Vector2(-5, 0), EffectController(duration: 0.05)),
      ]),
    );
  }

  /// Arrange marbles in balanced rows at right-center of submit area
  void arrangeMarblesInRows(MarbleGroup group) {
    final marbles = group.marbles;
    if (marbles.isEmpty) return;

    const double marbleSpacing = 25.0; // Space between marbles
    const double rowSpacing = 25.0; // Space between rows
    const double rightMargin = 15.0; // Margin from right edge

    // Calculate optimal rows
    final marbleCount = marbles.length;
    int cols;

    if (marbleCount <= 2) {
      // 1 or 2 marbles: single row
      cols = marbleCount;
    } else if (marbleCount <= 4) {
      // 3-4 marbles: 2 rows
      cols = 2;
    } else if (marbleCount <= 6) {
      // 5-6 marbles: 2 rows
      cols = 3;
    } else {
      // 7+ marbles: 3 rows
      cols = (marbleCount / 3).ceil();
    }

    final rows = (marbleCount / cols).ceil();

    // Calculate grid dimensions
    final gridWidth = (cols - 1) * marbleSpacing; // Space between marbles
    final gridHeight = (rows - 1) * rowSpacing;

    // Position at right-center of submit area
    // Right: position.x + size.x - gridWidth - rightMargin
    // Center vertically: position.y + size.y/2 - gridHeight/2
    final startX = position.x + size.x - gridWidth - rightMargin;
    final startY = position.y + (size.y - gridHeight) / 2;

    // Position each marble
    for (int i = 0; i < marbles.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;

      final x = startX + col * marbleSpacing;
      final y = startY + row * rowSpacing;

      marbles[i].position = Vector2(x, y);
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
