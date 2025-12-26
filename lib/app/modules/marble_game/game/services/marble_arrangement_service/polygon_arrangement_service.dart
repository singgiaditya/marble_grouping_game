import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/services/marble_arrangement_service/marble_arrangement_service.dart';

/// Polygon arrangement
class PolygonArrangementService implements MarbleArrangementService {
  final double radius;

  PolygonArrangementService({
    this.radius = GameConstants.groupArrangementRadius,
  });

  @override
  void arrange(List<Marble> marbles, Vector2 center) {
    if (marbles.isEmpty) return;

    if (marbles.length == 1) {
      // Single marble stays at center
      return;
    } else if (marbles.length == 2) {
      // Two marbles: position on opposite sides
      _positionMarble(marbles[0], center, radius, 0.0);
      _positionMarble(marbles[1], center, radius, pi);
    } else {
      // All marbles arranged in circle (radial layout)
      final angleStep = (2 * pi) / marbles.length;
      for (int i = 0; i < marbles.length; i++) {
        final angle = i * angleStep;
        _positionMarble(marbles[i], center, radius, angle);
      }
    }
  }

  /// Position a marble at a specific angle around center
  void _positionMarble(
    Marble marble,
    Vector2 center,
    double radius,
    double angle,
  ) {
    final targetX = center.x + radius * cos(angle);
    final targetY = center.y + radius * sin(angle);
    final targetPosition = Vector2(targetX, targetY);

    // Animate to target position
    marble.add(
      MoveToEffect(
        targetPosition,
        EffectController(
          duration: GameConstants.detachAnimationDuration,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}
