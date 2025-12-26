import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/submit_area.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/helpers/marble_animation_helper.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/marble_flame.dart';

/// Represents a single marble in the game
class Marble extends CircleComponent with DragCallbacks, DoubleTapCallbacks {
  // Group membership
  MarbleGroup? currentGroup;

  // Color management
  Color currentColor;
  final Color defaultColor;

  // Drag state
  bool isDragging = false;

  Marble({
    super.position,
    super.radius = GameConstants.defaultMarbleRadius,
    super.anchor = Anchor.center,
    Color? color,
  }) : currentColor = color ?? MyColor.primary,
       defaultColor = color ?? MyColor.primary;

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    updatePaintLayers();
  }

  /// Update paint layers with current colors
  void updatePaintLayers({Color? borderColor}) {
    paintLayers = [
      Paint()
        ..color = borderColor ?? MyColor.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = GameConstants.marbleBorderWidth,
      Paint()
        ..color = currentColor
        ..style = PaintingStyle.fill,
    ];
  }

  /// Change marble color (used when submitting to area)
  void changeColor(Color newColor, {Color? borderColor}) {
    currentColor = newColor;
    updatePaintLayers(borderColor: borderColor);
  }

  /// Animate color transition to target color
  void animateColorTransition(Color targetColor) {
    MarbleAnimationHelper.animateColorTransition(this, targetColor);
  }

  /// Play merge animation (bounce effect)
  void playMergeAnimation() {
    MarbleAnimationHelper.playMergeAnimation(this);
  }

  /// Detach from current group
  void detachFromGroup() {
    if (currentGroup != null) {
      final group = currentGroup!;
      group.removeMarble(this);

      // Small push animation away from group center
      final groupCenter = group.marbles.isNotEmpty
          ? group.marbles.fold<Vector2>(
                  Vector2.zero(),
                  (sum, m) => sum + m.position,
                ) /
                group.marbles.length.toDouble()
          : position;

      final pushDirection = (position - groupCenter).normalized();
      final pushTarget = position + pushDirection * 30;

      add(
        MoveToEffect(
          pushTarget,
          EffectController(
            duration: GameConstants.detachAnimationDuration,
            curve: Curves.easeOut,
          ),
        ),
      );
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    // Prevent drag during reset animation
    final game = findParent<MarbleFlame>();
    if (game != null && game.isResetting) {
      return;
    }

    isDragging = true;

    // Handle group drag
    if (currentGroup != null) {
      _handleGroupDragStart();
    } else {
      _handleSingleDragStart();
    }
  }

  /// Handle drag start for grouped marble
  void _handleGroupDragStart() {
    // Increase group priority so lines render above marbles
    currentGroup!.priority = GameConstants.groupDraggingPriority;

    for (final marble in currentGroup!.marbles) {
      MarbleAnimationHelper.applyDragScale(marble);
    }
  }

  /// Handle drag start for single marble
  void _handleSingleDragStart() {
    MarbleAnimationHelper.applyDragScale(this);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isDragging && parent != null) {
      final delta = event.localDelta;

      // If marble is in a group, move the entire group
      if (currentGroup != null) {
        for (final marble in currentGroup!.marbles) {
          marble.position += delta;
        }
      } else {
        // Otherwise, just move this marble
        position += delta;
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    isDragging = false;

    // Handle submitted group drag behavior
    if (currentGroup != null &&
        currentGroup!.isSubmitted &&
        currentGroup!.assignedArea != null) {
      _handleSubmittedGroupDragEnd();
      return;
    }

    // Check if group should be submitted to a submit area
    if (currentGroup != null && !currentGroup!.isSubmitted) {
      _checkSubmitAreas();
    }

    // Reset scale effects
    _resetScaleEffects();
  }

  /// Handle drag end for submitted groups
  void _handleSubmittedGroupDragEnd() {
    final area = currentGroup!.assignedArea!;

    // Check if dragged far enough to unsubmit
    final groupCenter = currentGroup!.calculateGroupCenter();
    final areaCenter = area.snapPosition;
    final distance = (groupCenter - areaCenter).length;

    if (distance > GameConstants.unsubmitThreshold) {
      // Unsubmit the group
      _unsubmitGroup();
    } else {
      // Bounce back to submit area
      _bounceBackToArea(area);
    }

    _resetScaleEffects();
  }

  /// Unsubmit group from submit area
  void _unsubmitGroup() {
    if (currentGroup == null || currentGroup!.assignedArea == null) return;

    final area = currentGroup!.assignedArea!;

    // Remove from area
    area.removeGroup();
    currentGroup!.isSubmitted = false;

    // Show connection lines again
    currentGroup!.showConnectionLines();

    // Reset marble colors to group color
    currentGroup!.changeMarbleColors(currentGroup!.groupColor);

    // Rebuild group pattern (circular arrangement)
    currentGroup!.arrangeMarbles();
  }

  /// Bounce group back to submit area
  void _bounceBackToArea(SubmitArea area) {
    if (currentGroup == null) return;

    // Rearrange marbles back to submit positions
    area.arrangeMarblesInRows(currentGroup!);

    // Add bounce effect to each marble
    for (final marble in currentGroup!.marbles) {
      marble.add(
        SequenceEffect([
          ScaleEffect.to(
            Vector2.all(GameConstants.mergeBounceScale),
            EffectController(duration: GameConstants.bounceAnimationDuration),
          ),
          ScaleEffect.to(
            Vector2.all(1.0),
            EffectController(duration: GameConstants.bounceAnimationDuration),
          ),
        ]),
      );
    }
  }

  /// Reset scale effects for all marbles in group or single marble
  void _resetScaleEffects() {
    if (currentGroup != null) {
      // Reset group priority
      currentGroup!.priority = GameConstants.connectionLinePriority;

      for (final marble in currentGroup!.marbles) {
        MarbleAnimationHelper.resetScaleEffects(marble);
      }
    } else {
      MarbleAnimationHelper.resetScaleEffects(this);
    }
  }

  /// Check if group overlaps with any submit area and submit if so
  void _checkSubmitAreas() {
    if (currentGroup == null) return;

    final game = findParent<MarbleFlame>();
    if (game == null) return;

    for (final area in game.submitAreas) {
      if (area.containsGroup(currentGroup!)) {
        area.submitGroup(currentGroup!);
        break; // Only submit to one area
      }
    }
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    super.onDoubleTapDown(event);

    // Prevent double-tap during reset animation
    final game = findParent<MarbleFlame>();
    if (game != null && game.isResetting) {
      return;
    }

    _handleDoubleTap();
  }

  /// Handle double tap to detach from group
  void _handleDoubleTap() {
    // Prevent detach if group is submitted
    if (currentGroup != null && currentGroup!.isSubmitted) {
      return;
    }

    // Detach from group on double-tap
    if (currentGroup != null) {
      detachFromGroup();
    }
  }
}
