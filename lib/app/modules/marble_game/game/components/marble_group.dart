import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/submit_area.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/strategies/marble_arrangement_strategy.dart';

/// Manages a group of marbles with visual connections and animations
class MarbleGroup extends Component {
  final List<Marble> marbles = [];
  final List<_ConnectionLine> _connectionLines = [];
  late MarbleArrangementStrategy _arrangementStrategy;

  SubmitArea? assignedArea;
  bool isSubmitted = false;
  bool? isCorrect;

  Color groupColor;
  final double proximityThreshold;

  // Animation state
  bool _linesAnimated = false;
  bool _linesHidden = false;

  MarbleGroup({
    this.groupColor = const Color(0xFF64B5F6), // Soft blue default
    this.proximityThreshold = GameConstants.proximityThreshold,
  }) {
    // Set priority to ensure proper rendering order
    priority = GameConstants.connectionLinePriority;

    // Initialize with radial arrangement strategy
    _arrangementStrategy = RadialArrangementStrategy();
  }

  /// Add a marble to this group with animation
  void addMarble(Marble marble) {
    if (marbles.contains(marble)) return;

    marbles.add(marble);
    marble.currentGroup = this;

    // Animate color transition
    marble.animateColorTransition(groupColor);

    // Play merge animation
    marble.playMergeAnimation();

    // Calculate and animate to pattern position
    arrangeMarbles();

    // Rebuild connection lines
    _rebuildConnectionLines();

    // Animate new lines
    _animateLines();
  }

  /// Arrange marbles using the current strategy
  void arrangeMarbles() {
    if (marbles.isEmpty) return;

    final center = _calculateGroupCenter();
    _arrangementStrategy.arrange(marbles, center);
  }

  /// Remove a marble from this group
  void removeMarble(Marble marble) {
    if (!marbles.contains(marble)) return;

    marbles.remove(marble);
    marble.currentGroup = null;

    // Reset marble color to default
    marble.animateColorTransition(marble.defaultColor);

    // If only 1 marble remains, disband the group
    if (marbles.length == 1) {
      final lastMarble = marbles.first;
      lastMarble.currentGroup = null;
      lastMarble.animateColorTransition(lastMarble.defaultColor);
      marbles.clear();
      removeFromParent();
      return;
    }

    // If group is empty, remove it
    if (marbles.isEmpty) {
      removeFromParent();
      return;
    }

    // Rearrange remaining marbles into new pattern
    arrangeMarbles();

    // Rebuild connection lines
    _rebuildConnectionLines();

    // Animate lines to make them visible
    _animateLines();
  }

  /// Rebuild connection lines based on current marble positions
  /// Creates a Ring Pattern (Polygon) - only adjacent marbles connected
  void _rebuildConnectionLines() {
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
  }

  /// Animate connection lines appearing
  void _animateLines() {
    // Make lines visible immediately to match original behavior
    _linesAnimated = true;
  }

  /// Calculate the geometric center of all marbles in the group
  Vector2 _calculateGroupCenter() {
    if (marbles.isEmpty) return Vector2.zero();

    Vector2 sum = Vector2.zero();
    for (final marble in marbles) {
      sum += marble.position;
    }
    return sum / marbles.length.toDouble();
  }

  /// Snap this group to a submit area
  void snapToSubmitArea(SubmitArea area) {
    assignedArea = area;
    isSubmitted = true;

    final snapPosition = area.snapPosition;

    // Animate all marbles to maintain their relative positions
    final center = _calculateGroupCenter();

    for (final marble in marbles) {
      final offset = marble.position - center;
      final targetPosition = snapPosition + offset;

      marble.add(
        MoveEffect.to(
          targetPosition,
          EffectController(
            duration: GameConstants.submitSnapDuration,
            curve: Curves.easeOut,
          ),
        ),
      );
    }
  }

  /// Return this group to the play area (when answer is incorrect)
  void returnToPlayArea() {
    assignedArea = null;
    isSubmitted = false;
    isCorrect = null;
  }

  /// Check if a position is within this group's bounds
  bool containsPosition(Vector2 position) {
    for (final marble in marbles) {
      if ((marble.position - position).length <= marble.radius) {
        return true;
      }
    }
    return false;
  }

  /// Get the bounding box of this group
  Rect getBoundingBox() {
    if (marbles.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final marble in marbles) {
      final pos = marble.position;
      final r = marble.radius;

      minX = minX < pos.x - r ? minX : pos.x - r;
      minY = minY < pos.y - r ? minY : pos.y - r;
      maxX = maxX > pos.x + r ? maxX : pos.x + r;
      maxY = maxY > pos.y + r ? maxY : pos.y + r;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update connection lines to follow marble positions in real-time
    if (_linesAnimated && marbles.length >= 2) {
      for (int i = 0; i < marbles.length && i < _connectionLines.length; i++) {
        final nextIndex = (i + 1) % marbles.length;
        _connectionLines[i].start = marbles[i].position.clone();
        _connectionLines[i].end = marbles[nextIndex].position.clone();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render connection lines (skip if hidden)
    if (_linesAnimated && !_linesHidden) {
      for (final line in _connectionLines) {
        line.render(canvas);
      }
    }
  }

  /// Hide connection lines (for submitted groups)
  void hideConnectionLines() {
    _linesHidden = true;
  }

  /// Show connection lines
  void showConnectionLines() {
    _linesHidden = false;
  }

  /// Change all marble colors to match submit area
  void changeMarbleColors(Color newColor, {Color? borderColor}) {
    for (final marble in marbles) {
      marble.changeColor(newColor, borderColor: borderColor);
    }
  }

  /// Calculate the geometric center of all marbles in the group
  Vector2 calculateGroupCenter() {
    if (marbles.isEmpty) return Vector2.zero();

    Vector2 sum = Vector2.zero();
    for (final marble in marbles) {
      sum += marble.position;
    }
    return sum / marbles.length.toDouble();
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
