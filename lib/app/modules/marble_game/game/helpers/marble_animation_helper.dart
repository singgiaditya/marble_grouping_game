import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';

/// Helper class for marble-specific animations
class MarbleAnimationHelper {
  /// Play merge animation (bounce effect) on a marble
  static void playMergeAnimation(Marble marble) {
    // Remove any existing scale effects to prevent conflicts
    marble.children.whereType<ScaleEffect>().forEach(
      (effect) => effect.removeFromParent(),
    );

    marble.add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(GameConstants.mergeBounceScale),
          EffectController(
            duration: GameConstants.mergeAnimationDuration,
            curve: Curves.easeOut,
          ),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(
            duration: GameConstants.mergeAnimationDuration,
            curve: Curves.easeIn,
          ),
        ),
      ]),
    );
  }

  /// Animate color transition to target color
  static void animateColorTransition(Marble marble, Color targetColor) {
    // Remove any existing color effects
    marble.children.whereType<ColorEffect>().forEach(
      (effect) => effect.removeFromParent(),
    );

    marble.add(
      ColorEffect(
        targetColor,
        EffectController(
          duration: GameConstants.colorTransitionDuration,
          curve: Curves.easeInOut,
        ),
        opacityTo: 1.0,
        onComplete: () {
          marble.currentColor = targetColor;
          marble.updatePaintLayers(borderColor: null);
        },
      ),
    );
  }

  /// Bounce marble back to a position
  static void bounceBackToPosition(Marble marble, Vector2 targetPosition) {
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

    marble.position = targetPosition;
  }

  /// Reset scale effects for a marble
  static void resetScaleEffects(Marble marble) {
    // Remove ALL effects
    marble.children.toList().forEach((child) {
      if (child is ScaleEffect || child is SequenceEffect) {
        child.removeFromParent();
      }
    });

    // Force reset scale to 1.0
    marble.scale = Vector2.all(1.0);

    // Reset priority
    marble.priority = GameConstants.defaultPriority;
  }

  /// Apply drag scale to marble
  static void applyDragScale(Marble marble) {
    // Remove ALL effects first
    marble.children.toList().forEach((child) {
      if (child is ScaleEffect || child is SequenceEffect) {
        child.removeFromParent();
      }
    });

    // Force reset scale to 1.0
    marble.scale = Vector2.all(1.0);

    // Apply drag scale
    marble.add(
      ScaleEffect.to(
        Vector2.all(GameConstants.dragScaleFactor),
        EffectController(duration: GameConstants.bounceAnimationDuration),
      ),
    );

    // Bring to front
    marble.priority = GameConstants.draggingPriority;
  }
}
