import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/submit_area.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/marble_flame.dart';

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
    super.radius = 10,
    super.anchor = Anchor.center,
    Color? color,
  }) : currentColor = color ?? MyColor.primary,
       defaultColor = color ?? MyColor.primary;

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _updatePaint();
  }

  void _updatePaint({Color? borderColor}) {
    paintLayers = [
      Paint()
        ..color = borderColor ?? MyColor.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
      Paint()
        ..color = currentColor
        ..style = PaintingStyle.fill,
    ];
  }

  /// Change marble color (used when submitting to area)
  void changeColor(Color newColor, {Color? borderColor}) {
    currentColor = newColor;
    _updatePaint(borderColor: borderColor);
  }

  /// Animate color transition to target color
  void animateColorTransition(Color targetColor) {
    // Remove any existing color effects
    children.whereType<ColorEffect>().forEach(
      (effect) => effect.removeFromParent(),
    );

    add(
      ColorEffect(
        targetColor,
        EffectController(duration: 0.3, curve: Curves.easeInOut),
        opacityTo: 1.0,
        onComplete: () {
          currentColor = targetColor;
          _updatePaint();
        },
      ),
    );
  }

  /// Play merge animation (bounce effect)
  void playMergeAnimation() {
    // Remove any existing scale effects to prevent conflicts
    children.whereType<ScaleEffect>().forEach(
      (effect) => effect.removeFromParent(),
    );

    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.2),
          EffectController(duration: 0.1, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.1, curve: Curves.easeIn),
        ),
      ]),
    );
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
          EffectController(duration: 0.2, curve: Curves.easeOut),
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
      return; // Don't allow drag during reset
    }

    isDragging = true;

    // If in a group, apply scale to all group marbles
    if (currentGroup != null) {
      // Increase group priority so lines render above marbles
      currentGroup!.priority = 101;

      for (final marble in currentGroup!.marbles) {
        // Remove ALL effects to prevent accumulation
        marble.children.toList().forEach((child) {
          if (child is ScaleEffect || child is SequenceEffect) {
            child.removeFromParent();
          }
        });

        // Force reset scale to 1.0
        marble.scale = Vector2.all(1.0);

        // Apply drag scale to all marbles in group
        marble.add(
          ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.1)),
        );

        // Bring to front
        marble.priority = 100;
      }
    } else {
      // Single marble: remove ALL effects
      children.toList().forEach((child) {
        if (child is ScaleEffect || child is SequenceEffect) {
          child.removeFromParent();
        }
      });

      // Force reset scale to 1.0
      scale = Vector2.all(1.0);

      // Visual feedback: slight scale increase
      add(ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.1)));

      // Bring to front (higher priority)
      priority = 100;
    }
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
      final area = currentGroup!.assignedArea!;

      // Check if dragged far enough to unsubmit
      final groupCenter = currentGroup!.calculateGroupCenter();
      final areaCenter = area.snapPosition;
      final distance = (groupCenter - areaCenter).length;

      const double unsubmitThreshold = 80.0; // Distance to trigger unsubmit

      if (distance > unsubmitThreshold) {
        // Unsubmit the group
        _unsubmitGroup();
      } else {
        // Bounce back to submit area
        _bounceBackToArea(area);
      }

      // Reset scale effects
      _resetScaleEffects();
      return;
    }

    // Check if group should be submitted to a submit area
    if (currentGroup != null && !currentGroup!.isSubmitted) {
      _checkSubmitAreas();
    }

    // Reset scale effects
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
          ScaleEffect.to(Vector2.all(1.2), EffectController(duration: 0.1)),
          ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.1)),
        ]),
      );
    }
  }

  /// Reset scale effects for all marbles in group or single marble
  void _resetScaleEffects() {
    // If in a group, reset scale for all group marbles
    if (currentGroup != null) {
      // Reset group priority
      currentGroup!.priority = 1;

      for (final marble in currentGroup!.marbles) {
        // Remove ALL effects
        marble.children.toList().forEach((child) {
          if (child is ScaleEffect || child is SequenceEffect) {
            child.removeFromParent();
          }
        });

        // Force reset scale to 1.0
        marble.scale = Vector2.all(1.0);

        // Reset priority
        marble.priority = 0;
      }
    } else {
      // Single marble: remove ALL effects
      children.toList().forEach((child) {
        if (child is ScaleEffect || child is SequenceEffect) {
          child.removeFromParent();
        }
      });

      // Force reset scale to 1.0
      scale = Vector2.all(1.0);

      // Reset priority
      priority = 0;
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
      return; // Don't allow double-tap during reset
    }

    _handleDoubleTap();
  }

  void _handleDoubleTap() {
    // Prevent detach if group is submitted
    if (currentGroup != null && currentGroup!.isSubmitted) {
      return; // Don't allow detach for submitted groups
    }

    // Detach from group on double-tap
    if (currentGroup != null) {
      detachFromGroup();
    }
  }
}
