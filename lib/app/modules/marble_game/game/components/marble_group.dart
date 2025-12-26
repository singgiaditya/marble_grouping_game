import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/submit_area.dart';

/// Manages a group of marbles with visual connections and animations
class MarbleGroup extends Component {
  final List<Marble> marbles = [];
  final List<_ConnectionLine> _connectionLines = [];

  SubmitArea? assignedArea;
  bool isSubmitted = false;
  bool? isCorrect;

  Color groupColor;
  final double proximityThreshold;

  // Animation state
  bool _linesAnimated = false;
  bool _linesHidden = false; // Hide lines when submitted

  MarbleGroup({
    this.groupColor = const Color(0xFF64B5F6), // Soft blue default
    this.proximityThreshold = 40.0,
  }) {
    // Set priority to 1 to ensure connection lines render above marbles
    priority = 1;
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

  /// Arrange marbles in radial pattern (all in circle)
  void arrangeMarbles() {
    if (marbles.isEmpty) return;

    final center = _calculateGroupCenter();
    final radius = 30.0; // Distance from center

    if (marbles.length == 1) {
      // Single marble stays at its position
      return;
    } else if (marbles.length == 2) {
      // Two marbles: position on opposite sides
      final angle1 = 0.0;
      final angle2 = pi;
      _positionMarble(marbles[0], center, radius, angle1);
      _positionMarble(marbles[1], center, radius, angle2);
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
        EffectController(duration: 0.2, curve: Curves.easeOut),
      ),
    );
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
    // This creates a polygon with n edges (much more efficient than n(n-1)/2)
    for (int i = 0; i < marbles.length; i++) {
      final nextIndex = (i + 1) % marbles.length;
      _connectionLines.add(
        _ConnectionLine(
          start: marbles[i].position.clone(),
          end: marbles[nextIndex].position.clone(),
          color: Colors.white.withOpacity(0.8),
        ),
      );
    }

    _linesAnimated = false;
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

  /// Animate connection lines appearing sequentially
  void _animateLines() {
    _linesAnimated = false;

    // Sequential animation: 100ms per line
    final totalDuration = _connectionLines.length * 0.1;

    // Use a simple timer effect instead of OpacityEffect
    // since MarbleGroup doesn't implement OpacityProvider
    add(
      TimerComponent(
        period: totalDuration,
        removeOnFinish: true,
        onTick: () {
          _linesAnimated = true;
        },
      ),
    );
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
        MoveToEffect(
          targetPosition,
          EffectController(duration: 0.3, curve: Curves.easeOut),
        ),
      );
    }
  }

  /// Return this group to the play area (when answer is incorrect)
  void returnToPlayArea() {
    assignedArea = null;
    isSubmitted = false;
    isCorrect = null;

    // Animate marbles back to a random position in play area
    // This will be handled by the game controller
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
      // Update ring connections to match current marble positions
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
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(start.x, start.y), Offset(end.x, end.y), paint);
  }
}
