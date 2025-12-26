import 'package:flame/components.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';

/// Strategy interface for arranging marbles in different patterns
abstract class MarbleArrangementService {
  /// Arrange marbles according to the strategy
  void arrange(List<Marble> marbles, Vector2 center);
}
