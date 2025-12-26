import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/services/marble_arrangement_service/row_arrangement_service.dart';

/// Submit area where marble groups can be placed for answer validation
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

    // Change marble colors to match submit area (with shadow color for border)
    group.changeMarbleColors(bgColor, borderColor: shadowColor);

    // Arrange marbles in rows at right-center of submit area
    arrangeMarblesInRows(group);

    return true;
  }

  /// Show error effect when trying to submit to full area
  void _showErrorEffect() {
    add(
      SequenceEffect([
        MoveEffect.by(
          Vector2(GameConstants.errorShakeDistance, 0),
          EffectController(duration: GameConstants.errorShakeDuration),
        ),
        MoveEffect.by(
          Vector2(-GameConstants.errorShakeDistance * 2, 0),
          EffectController(duration: GameConstants.errorShakeDuration * 2),
        ),
        MoveEffect.by(
          Vector2(GameConstants.errorShakeDistance * 2, 0),
          EffectController(duration: GameConstants.errorShakeDuration * 2),
        ),
        MoveEffect.by(
          Vector2(-GameConstants.errorShakeDistance, 0),
          EffectController(duration: GameConstants.errorShakeDuration),
        ),
      ]),
    );
  }

  /// Arrange marbles in balanced rows at right-center of submit area
  void arrangeMarblesInRows(MarbleGroup group) {
    final startPosition = Vector2(position.x + size.x, position.y + size.y / 2);

    final strategy = RowArrangementService(
      startPosition: startPosition,
      marbleSpacing: GameConstants.marbleSpacing,
      rowSpacing: GameConstants.rowSpacing,
    );

    strategy.arrange(group.marbles, startPosition);
  }

  /// Highlight the area (visual feedback when group is hovering)
  void highlightArea(bool highlight) {
    isHighlighted = highlight;
  }

  @override
  void render(Canvas canvas) {
    // Draw shadow
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 4, size.x, size.y),
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
      ..color = Colors.white.withValues(alpha: GameConstants.highlightOpacity)
      ..style = PaintingStyle.fill;

    size = Vector2(size.x, size.y);
  }
}
