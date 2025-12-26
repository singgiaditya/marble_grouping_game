import 'package:flame/components.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/services/marble_arrangement_service/marble_arrangement_service.dart';

/// Row arrangement - marbles in balanced rows
class RowArrangementService implements MarbleArrangementService {
  final Vector2 startPosition;
  final double marbleSpacing;
  final double rowSpacing;

  RowArrangementService({
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
