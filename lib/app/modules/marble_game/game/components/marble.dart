import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';

class Marble extends CircleComponent with DragCallbacks, TapCallbacks {
  // Group membership
  MarbleGroup? currentGroup;

  // Color management
  Color currentColor;
  final Color defaultColor;

  // Drag state
  bool isDragging = false;

  // Double-tap detection
  int _tapCount = 0;
  double? _tapTimer;
  static const _doubleTapWindow = 0.3; // seconds

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

  void _updatePaint() {
    paintLayers = [
      Paint()
        ..color = MyColor.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
      Paint()
        ..color = currentColor
        ..style = PaintingStyle.fill,
    ];
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
    isDragging = true;

    // If in a group, apply scale to all group marbles
    if (currentGroup != null) {
      for (final marble in currentGroup!.marbles) {
        // Remove any existing scale effects
        marble.children.whereType<ScaleEffect>().toList().forEach(
          (effect) => effect.removeFromParent(),
        );
        marble.children.whereType<SequenceEffect>().toList().forEach(
          (effect) => effect.removeFromParent(),
        );

        // Reset scale to 1.0 first
        marble.scale = Vector2.all(1.0);

        // Apply drag scale to all marbles in group
        marble.add(
          ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.1)),
        );

        // Bring to front
        marble.priority = 100;
      }
    } else {
      // Single marble: remove existing effects
      children.whereType<ScaleEffect>().toList().forEach(
        (effect) => effect.removeFromParent(),
      );
      children.whereType<SequenceEffect>().toList().forEach(
        (effect) => effect.removeFromParent(),
      );

      // Reset scale to 1.0 first, then apply drag scale
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

    // If in a group, reset scale for all group marbles
    if (currentGroup != null) {
      for (final marble in currentGroup!.marbles) {
        // Remove any existing scale effects
        marble.children.whereType<ScaleEffect>().toList().forEach(
          (effect) => effect.removeFromParent(),
        );

        // Reset scale to 1.0 immediately
        marble.scale = Vector2.all(1.0);

        // Reset priority
        marble.priority = 0;
      }
    } else {
      // Single marble: remove existing effects
      children.whereType<ScaleEffect>().toList().forEach(
        (effect) => effect.removeFromParent(),
      );

      // Reset scale to 1.0 immediately
      scale = Vector2.all(1.0);

      // Reset priority
      priority = 0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    _tapCount++;

    // Reset timer
    _tapTimer = _doubleTapWindow;

    if (_tapCount == 2) {
      // Double-tap detected
      _handleDoubleTap();
      _tapCount = 0;
      _tapTimer = null;
    }
  }

  void _handleDoubleTap() {
    // Detach from group on double-tap
    if (currentGroup != null) {
      detachFromGroup();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update tap timer
    if (_tapTimer != null) {
      _tapTimer = _tapTimer! - dt;
      if (_tapTimer! <= 0) {
        _tapTimer = null;
        _tapCount = 0;
      }
    }
  }
}
