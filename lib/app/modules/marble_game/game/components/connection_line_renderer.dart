import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';

/// Component responsible for rendering connection lines between marbles
class ConnectionLineRenderer extends Component {
  final List<_ConnectionLine> _connectionLines = [];
  bool _linesAnimated = false;
  bool _linesHidden = false;

  ConnectionLineRenderer() {
    priority = GameConstants.connectionLinePriority;
  }

  /// Rebuild connection lines based on marble positions
  /// Creates a Ring Pattern (Polygon) - only adjacent marbles connected
  void rebuildConnectionLines(List<Marble> marbles) {
    _connectionLines.clear();

    if (marbles.length < 2) return;

    // Ring pattern: connect each marble to the next one in circle
    for (int i = 0; i < marbles.length; i++) {
      final nextIndex = (i + 1) % marbles.length;
      _connectionLines.add(
        _ConnectionLine(
          start: marbles[i].position.clone(),
          end: marbles[nextIndex].position.clone(),
          color: Colors.white.withValues(
            alpha: GameConstants.connectionLineOpacity,
          ),
        ),
      );
    }

    // Don't reset _linesAnimated here - let animateLines() control visibility
  }

  /// Update connection line positions to follow marbles
  void updateLinePositions(List<Marble> marbles) {
    if (!_linesAnimated || marbles.length < 2) return;

    for (int i = 0; i < marbles.length && i < _connectionLines.length; i++) {
      final nextIndex = (i + 1) % marbles.length;
      _connectionLines[i].start = marbles[i].position.clone();
      _connectionLines[i].end = marbles[nextIndex].position.clone();
    }
  }

  /// Animate connection lines appearing
  void animateLines() {
    // Make lines visible immediately
    _linesAnimated = true;

    // Optional: Add fade-in animation in the future if needed
    // For now, lines appear immediately to match original behavior
  }

  /// Hide connection lines
  void hideLines() {
    _linesHidden = true;
  }

  /// Show connection lines
  void showLines() {
    _linesHidden = false;
  }

  /// Check if lines are visible
  bool get areLinesVisible => _linesAnimated && !_linesHidden;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (areLinesVisible) {
      for (final line in _connectionLines) {
        line.render(canvas);
      }
    }
  }
}

/// Represents a connection line between marbles
class _ConnectionLine {
  Vector2 start;
  Vector2 end;
  Color color;

  _ConnectionLine({
    required this.start,
    required this.end,
    required this.color,
  });

  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = GameConstants.connectionLineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(start.x, start.y), Offset(end.x, end.y), paint);
  }
}
