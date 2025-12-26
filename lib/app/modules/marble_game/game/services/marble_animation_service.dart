import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/services/marble_positioning_service.dart';

/// Service responsible for marble animations
class MarbleAnimationService {
  final Component gameComponent;
  final Vector2 gameSize;
  final double marbleRadius;
  final MarblePositioningService positioningService;

  MarbleAnimationService({
    required this.gameComponent,
    required this.gameSize,
    required this.marbleRadius,
    required this.positioningService,
  });

  /// Get center position of the game
  Vector2 get centerPosition => Vector2(gameSize.x / 2, gameSize.y / 2);

  /// Animate all marbles to center
  void animateMarblesToCenter(List<Marble> marbles) {
    for (final marble in marbles) {
      marble.add(
        MoveToEffect(
          centerPosition,
          EffectController(
            duration: GameConstants.moveToCenterDuration,
            curve: Curves.easeInOut,
          ),
        ),
      );
    }
  }

  /// Animate a single marble to a random position
  void animateMarbleToRandom(Marble marble) {
    final position = positioningService.findValidRandomPosition();
    if (position != null) {
      marble.add(
        MoveToEffect(
          position,
          EffectController(
            duration: GameConstants.spreadAnimationDuration,
            curve: Curves.easeOut,
          ),
        ),
      );
    }
  }

  /// Spread marbles from center to random positions
  void spreadMarbles(List<Marble> marbles) {
    final positions = positioningService.generateSpreadPositions(
      marbles.length,
    );

    for (int i = 0; i < marbles.length && i < positions.length; i++) {
      marbles[i].add(
        MoveToEffect(
          positions[i],
          EffectController(
            duration: GameConstants.spreadAnimationDuration,
            curve: Curves.easeOut,
          ),
        ),
      );
    }
  }

  /// Detach all marbles from their groups with staggered animation
  void detachAllGroups(List<MarbleGroup> groups) {
    final List<Marble> marblesToDetach = [];
    for (final group in groups) {
      marblesToDetach.addAll(group.marbles.toList());
    }

    if (marblesToDetach.isEmpty) return;

    for (int i = 0; i < marblesToDetach.length; i++) {
      final marble = marblesToDetach[i];
      final delay = i * GameConstants.detachStaggerDelay;

      gameComponent.add(
        TimerComponent(
          period: delay,
          removeOnFinish: true,
          onTick: () {
            if (marble.currentGroup != null) {
              marble.currentGroup!.removeMarble(marble);
            }
          },
        ),
      );
    }
  }

  /// Calculate total time needed for detachment animation
  double calculateDetachmentTime(int marbleCount) {
    return marbleCount * GameConstants.detachStaggerDelay +
        GameConstants.detachmentBufferTime;
  }

  /// Update marbles with animation sequence
  /// 1. Detach from groups
  /// 2. Animate to center
  /// 3. Adjust count (add/remove marbles)
  /// 4. Ready for spread
  void updateMarblesWithAnimation({
    required List<Marble> currentMarbles,
    required List<MarbleGroup> groups,
    required int targetCount,
    required Function(int count) onCenterAnimationComplete,
  }) {
    positioningService.clearOccupiedPositions();

    // Collect marbles to detach
    final List<Marble> marblesToDetach = [];
    for (final group in groups) {
      marblesToDetach.addAll(group.marbles.toList());
    }

    if (marblesToDetach.isNotEmpty) {
      // Step 1: Detach with stagger
      detachAllGroups(groups);

      final detachmentTime = calculateDetachmentTime(marblesToDetach.length);

      // Step 2: After detachment, animate to center
      gameComponent.add(
        TimerComponent(
          period: detachmentTime,
          removeOnFinish: true,
          onTick: () {
            onCenterAnimationComplete(targetCount);
          },
        ),
      );
    } else {
      // No groups, go straight to center
      onCenterAnimationComplete(targetCount);
    }
  }

  /// Animate marbles back to random positions (for wrong answer)
  void returnMarblesToPlayArea(List<Marble> marbles) {
    for (final marble in marbles) {
      animateMarbleToRandom(marble);
    }
  }
}
