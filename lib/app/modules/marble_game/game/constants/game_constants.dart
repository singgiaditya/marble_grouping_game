/// Game constants for marble grouping game
/// Centralizes all magic numbers and configuration values
class GameConstants {
  // Private constructor to prevent instantiation
  GameConstants._();

  // === Proximity & Distance ===
  /// Threshold distance for marbles to group together
  static const double proximityThreshold = 40.0;

  /// Minimum distance between marbles when spreading
  static const double minMarbleDistance = 50.0;

  /// Distance threshold to trigger unsubmit from submit area
  static const double unsubmitThreshold = 80.0;

  // === Spacing & Layout ===
  /// Space between marbles in a group
  static const double marbleSpacing = 25.0;

  /// Space between rows in submit area
  static const double rowSpacing = 25.0;

  /// Radius for circular marble arrangement in groups
  static const double groupArrangementRadius = 30.0;

  /// Left margin for marble spreading area
  static const double leftMargin = 80.0;

  // === Animation Durations ===
  /// Duration for marble merge animation
  static const double mergeAnimationDuration = 0.1;

  /// Duration for color transition animation
  static const double colorTransitionDuration = 0.3;

  /// Duration for move to center animation
  static const double moveToCenterDuration = 0.6;

  /// Duration for spread animation
  static const double spreadAnimationDuration = 1.0;

  /// Duration for detach animation
  static const double detachAnimationDuration = 0.2;

  /// Duration for bounce animation
  static const double bounceAnimationDuration = 0.1;

  /// Duration for submit snap animation
  static const double submitSnapDuration = 0.3;

  /// Delay between staggered detachment animations
  static const double detachStaggerDelay = 0.05;

  /// Buffer time for detachment completion
  static const double detachmentBufferTime = 0.6;

  /// Duration per connection line animation
  static const double lineAnimationDuration = 0.1;

  // === Scale & Size ===
  /// Default marble radius
  static const double defaultMarbleRadius = 10.0;

  /// Scale factor when dragging marble
  static const double dragScaleFactor = 1.1;

  /// Scale factor for merge bounce effect
  static const double mergeBounceScale = 1.2;

  // === Visual Effects ===
  /// Border stroke width for marbles
  static const double marbleBorderWidth = 4.0;

  /// Connection line stroke width
  static const double connectionLineWidth = 2.0;

  /// Connection line opacity
  static const double connectionLineOpacity = 0.8;

  /// Highlight overlay opacity for submit areas
  static const double highlightOpacity = 0.2;

  // === Shake Animation ===
  /// Horizontal shake distance
  static const double shakeDistance = 3.0;

  /// Shake animation duration per step
  static const double shakeDuration = 0.1;

  /// Number of shake repetitions
  static const int shakeRepeatCount = 3;

  // === Error Effect ===
  /// Error shake distance for submit area
  static const double errorShakeDistance = 5.0;

  /// Error shake duration
  static const double errorShakeDuration = 0.05;

  // === Positioning ===
  /// Maximum attempts to find valid position
  static const int maxPositioningAttempts = 100;

  // === Priorities ===
  /// Default component priority
  static const int defaultPriority = 0;

  /// Dragging component priority
  static const int draggingPriority = 100;

  /// Group priority when dragging
  static const int groupDraggingPriority = 101;

  /// Connection line renderer priority
  static const int connectionLinePriority = 1;
}
