import 'dart:math';

import 'package:flame/components.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';

/// Service responsible for marble positioning and collision detection
class MarblePositioningService {
  final List<Vector2> _occupiedPositions = [];
  final Vector2 gameSize;
  final double marbleRadius;

  MarblePositioningService({
    required this.gameSize,
    required this.marbleRadius,
  });

  /// Clear all occupied positions
  void clearOccupiedPositions() {
    _occupiedPositions.clear();
  }

  /// Check if a position is occupied within minimum distance
  bool isPositionOccupied(Vector2 position, double minDistance) {
    for (final occupied in _occupiedPositions) {
      if ((position - occupied).length < minDistance) {
        return true;
      }
    }
    return false;
  }

  /// Add a position to the occupied list
  void addOccupiedPosition(Vector2 position) {
    _occupiedPositions.add(position);
  }

  /// Find a valid random position for a marble
  /// Uses true random positioning for Packed Random Dot Cluster pattern
  Vector2? findValidRandomPosition({double? minDistance, Random? random}) {
    final effectiveMinDistance = minDistance ?? GameConstants.minMarbleDistance;
    final rng = random ?? Random();
    int attempts = 0;

    while (attempts < GameConstants.maxPositioningAttempts) {
      // True random positioning
      final randomX =
          GameConstants.leftMargin +
          marbleRadius +
          rng.nextDouble() *
              (gameSize.x - GameConstants.leftMargin - 2 * marbleRadius);

      final randomY =
          marbleRadius + rng.nextDouble() * (gameSize.y - 2 * marbleRadius);

      final position = Vector2(randomX, randomY);

      if (!isPositionOccupied(position, effectiveMinDistance)) {
        return position;
      }

      attempts++;
    }

    // Fallback position if no valid position found
    return Vector2(
      GameConstants.leftMargin +
          marbleRadius +
          (gameSize.x - GameConstants.leftMargin - 2 * marbleRadius) / 2,
      marbleRadius + (gameSize.y - 2 * marbleRadius) / 2,
    );
  }

  /// Spread marbles in a packed random pattern
  List<Vector2> generateSpreadPositions(int count) {
    clearOccupiedPositions();
    final positions = <Vector2>[];

    for (int i = 0; i < count; i++) {
      final position = findValidRandomPosition();
      if (position != null) {
        positions.add(position);
        addOccupiedPosition(position);
      }
    }

    return positions;
  }
}
