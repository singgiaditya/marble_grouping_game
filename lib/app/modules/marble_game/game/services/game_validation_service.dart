import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';

/// Service responsible for game validation and answer checking
class GameValidationService {
  final int targetGroupSize;
  final List<dynamic> submitAreas;

  GameValidationService({
    required this.targetGroupSize,
    required this.submitAreas,
  });

  /// Validate that all 3 submit areas have groups of the correct size
  bool validateSubmitAreas() {
    // Check that all 3 areas have a group
    for (final area in submitAreas) {
      if (area.assignedGroup == null) {
        return false;
      }

      // Check that each group has the correct number of marbles
      if (area.assignedGroup!.marbles.length != targetGroupSize) {
        return false;
      }
    }

    return true;
  }

  /// Check if answer is correct
  /// Returns true if all 3 submit areas have groups with correct count
  bool checkAnswer() {
    // Check if all 3 areas have groups
    for (final area in submitAreas) {
      if (area.assignedGroup == null) {
        return false; // Missing group in one or more areas
      }
    }

    // Check if all groups have the correct count (targetGroupSize)
    for (final area in submitAreas) {
      final group = area.assignedGroup!;
      if (group.marbles.length != targetGroupSize) {
        return false; // Wrong count
      }
    }

    return true; // All correct!
  }

  /// Shake wrong groups to indicate error
  void shakeWrongGroups() {
    for (final area in submitAreas) {
      if (area.assignedGroup != null) {
        final group = area.assignedGroup!;
        // Shake if count is wrong
        if (group.marbles.length != targetGroupSize) {
          _shakeGroup(group);
        }
      }
    }
  }

  /// Apply continuous shake animation to a group
  void _shakeGroup(MarbleGroup group) {
    // Add repeating shake effect to each marble in the group
    for (final marble in group.marbles) {
      // Remove any existing shake effects
      marble.children.whereType<SequenceEffect>().forEach((effect) {
        effect.removeFromParent();
      });

      // Add continuous shake effect
      final shakeEffect = SequenceEffect([
        MoveEffect.by(
          Vector2(GameConstants.shakeDistance, 0),
          EffectController(duration: GameConstants.shakeDuration),
        ),
        MoveEffect.by(
          Vector2(-GameConstants.shakeDistance * 2, 0),
          EffectController(duration: GameConstants.shakeDuration * 2),
        ),
        MoveEffect.by(
          Vector2(GameConstants.shakeDistance * 2, 0),
          EffectController(duration: GameConstants.shakeDuration * 2),
        ),
        MoveEffect.by(
          Vector2(-GameConstants.shakeDistance, 0),
          EffectController(duration: GameConstants.shakeDuration),
        ),
      ], repeatCount: GameConstants.shakeRepeatCount);

      marble.add(shakeEffect);
    }
  }

  /// Stop shaking all groups
  void stopShakingGroups() {
    for (final area in submitAreas) {
      if (area.assignedGroup != null) {
        final group = area.assignedGroup!;
        for (final marble in group.marbles) {
          // Remove shake effects
          marble.children.whereType<SequenceEffect>().toList().forEach((
            effect,
          ) {
            effect.removeFromParent();
          });
        }
      }
    }
  }
}
