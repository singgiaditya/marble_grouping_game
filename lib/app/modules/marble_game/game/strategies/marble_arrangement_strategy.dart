import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';

/// Strategy interface for arranging marbles in different patterns
abstract class MarbleArrangementStrategy {
  /// Arrange marbles according to the strategy
  void arrange(List<Marble> marbles, Vector2 center);
}

/// Radial arrangement - marbles in a circle
class RadialArrangementStrategy implements MarbleArrangementStrategy {
  final double radius;

  RadialArrangementStrategy({
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

/// Row arrangement - marbles in balanced rows
class RowArrangementStrategy implements MarbleArrangementStrategy {
  final Vector2 startPosition;
  final double marbleSpacing;
  final double rowSpacing;

  RowArrangementStrategy({
    required this.startPosition,
    this.marbleSpacing = GameConstants.marbleSpacing,
    this.rowSpacing = GameConstants.rowSpacing,
  });

  @override
  void arrange(List<Marble> marbles, Vector2 center) {
    if (marbles.isEmpty) return;

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
    final gridHeight = (rows - 1) * rowSpacing;

    // Position at startPosition, centered vertically
    final startY = startPosition.y - (gridHeight / 2);

    // Position each marble
    for (int i = 0; i < marbles.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;

      final x = startPosition.x + col * marbleSpacing;
      final y = startY + row * rowSpacing;

      marbles[i].position = Vector2(x, y);
    }
  }
}
