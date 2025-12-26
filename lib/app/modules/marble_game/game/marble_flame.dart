import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/submit_area.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';
import 'package:flame/effects.dart';

class MarbleFlame extends FlameGame {
  final Random _random = Random();
  final List<Vector2> _occupiedPositions = [];

  // Grouping system
  final List<MarbleGroup> groups = [];
  final double proximityThreshold = 40.0;

  // Game configuration
  int targetGroupSize = 4; // The result of division (e.g., 12 ÷ 3 = 4)
  int totalMarbles = 12; // result × 3

  // Submit areas
  late final List<SubmitArea> submitAreas;

  // Validation callback
  Function(bool isCorrect)? onAnswerValidated;

  // Reset state - prevents interaction during reset animation
  bool isResetting = false;

  @override
  Color backgroundColor() => const Color(0x00000000);

  double marbleRadius() => 10;

  Vector2 areaSize() => Vector2(60, (size.y / 3) - 20);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    // Ensure camera is centered at the center of the world
    camera.viewfinder.position = Vector2(size.x / 2, size.y / 2);
    camera.viewfinder.anchor = Anchor.center;

    _occupiedPositions.clear();
    // Don't create initial marbles here - let controller handle it

    final SubmitArea area1 = SubmitArea()
      ..size = areaSize()
      ..position = Vector2(0, 0);

    final SubmitArea area2 =
        SubmitArea(bgColor: MyColor.area2, shadowColor: MyColor.area2Shadow)
          ..size = areaSize()
          ..position = Vector2(0, area1.position.y + areaSize().y + 20);

    final SubmitArea area3 =
        SubmitArea(bgColor: MyColor.area3, shadowColor: MyColor.area3Shadow)
          ..size = areaSize()
          ..position = Vector2(0, area2.position.y + areaSize().y + 20);

    submitAreas = [area1, area2, area3];
    addAll(submitAreas);
  }

  void updateMarbles(int count) {
    _occupiedPositions.clear();

    // Collect all marbles that need to be detached
    final List<Marble> marblesToDetach = [];
    for (final group in groups) {
      marblesToDetach.addAll(group.marbles.toList());
    }

    // Step 1: Detach marbles one by one with staggered timing
    if (marblesToDetach.isNotEmpty) {
      for (int i = 0; i < marblesToDetach.length; i++) {
        final marble = marblesToDetach[i];
        final delay = i * 0.05; // 50ms between each detachment

        add(
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

      // Calculate total detachment time
      // Each marble: 50ms delay + 200ms detach animation + 300ms color fade
      final detachmentTime =
          marblesToDetach.length * 0.05 + 0.6; // Increased buffer

      // Step 2: After all detachments complete, animate to center
      add(
        TimerComponent(
          period: detachmentTime,
          removeOnFinish: true,
          onTick: () {
            animateMarblesToCenter(count);
          },
        ),
      );
    } else {
      // No groups to detach, go straight to center animation
      animateMarblesToCenter(count);
    }

    // Update total marbles for validation
    totalMarbles = count;
  }

  /// Detach all marbles from their groups with staggered animation
  void detachAllGroups() {
    final List<Marble> marblesToDetach = [];
    for (final group in groups) {
      marblesToDetach.addAll(group.marbles.toList());
    }

    if (marblesToDetach.isEmpty) return;

    for (int i = 0; i < marblesToDetach.length; i++) {
      final marble = marblesToDetach[i];
      final delay = i * 0.05; // 50ms between each detachment

      add(
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

  /// Clear all submit areas (unsubmit all groups)
  void clearAllSubmitAreas() {
    for (final area in submitAreas) {
      if (area.assignedGroup != null) {
        final group = area.assignedGroup!;

        // Unsubmit the group
        group.isSubmitted = false;

        // Show connection lines again
        group.showConnectionLines();

        // Reset marble colors to group color
        group.changeMarbleColors(group.groupColor);

        // Remove from area
        area.removeGroup();
      }
    }
  }

  /// Animate all marbles to center and adjust count
  void animateMarblesToCenter(int count) {
    final marbles = children.whereType<Marble>().toList();
    final center = Vector2(size.x / 2, size.y / 2);

    // Animate existing marbles to center first (don't add new ones yet)
    for (final marble in marbles) {
      marble.add(
        MoveToEffect(
          center,
          EffectController(duration: 0.6, curve: Curves.easeInOut),
        ),
      );
    }

    // Wait for center animation, then remove excess if needed
    add(
      TimerComponent(
        period: 0.7,
        removeOnFinish: true,
        onTick: () {
          final currentMarbles = children.whereType<Marble>().toList();

          // Remove excess marbles if count decreased
          if (currentMarbles.length > count) {
            for (int i = count; i < currentMarbles.length; i++) {
              remove(currentMarbles[i]);
            }
          } else if (currentMarbles.length < count) {
            // Add new marbles at center (creates illusion)
            for (int i = currentMarbles.length; i < count; i++) {
              final marble = Marble(radius: marbleRadius())..position = center;
              add(marble);
            }
          }
        },
      ),
    );
  }

  /// Spread marbles from center to random positions
  void spreadMarbles(int count) {
    // Small delay to ensure marbles are ready
    add(
      TimerComponent(
        period: 0.05,
        removeOnFinish: true,
        onTick: () {
          _spreadMarblesInPattern(count);
        },
      ),
    );
  }

  /// Spread marbles in a packed random dot cluster pattern
  /// Random positions with minimum distance to prevent overlap
  void _spreadMarblesInPattern(int count) {
    final marblesList = children.whereType<Marble>().toList();
    if (marblesList.isEmpty) return;

    // Clear occupied positions for fresh placement
    _occupiedPositions.clear();

    const double leftMargin = 80.0;
    const double minDistance = 50.0; // Minimum distance between marbles
    final radius = marbleRadius();

    // Position each marble randomly with distance constraints
    for (int i = 0; i < marblesList.length && i < count; i++) {
      Vector2 randomPosition;
      int attempts = 0;
      const int maxAttempts = 100;

      do {
        final randomX =
            leftMargin +
            radius +
            _random.nextDouble() * (size.x - leftMargin - 2 * radius);
        final randomY = radius + _random.nextDouble() * (size.y - 2 * radius);
        randomPosition = Vector2(randomX, randomY);
        attempts++;
      } while (_isPositionOccupied(randomPosition, minDistance) &&
          attempts < maxAttempts);

      // Add position to occupied list
      _occupiedPositions.add(randomPosition);

      // Animate marble to position
      marblesList[i].add(
        MoveToEffect(
          randomPosition,
          EffectController(duration: 1.0, curve: Curves.easeOut),
        ),
      );
    }
  }

  void _animateMarbleToRandom(Marble marble) {
    const double minDistance =
        30; // Minimum distance between marbles (2*radius + margin)
    const double leftMargin = 80; // Margin from left side
    double radius = marbleRadius();
    Vector2 randomPosition;
    int attempts = 0;
    const int maxAttempts = 100;

    do {
      final randomX =
          leftMargin +
          radius +
          _random.nextDouble() * (size.x - leftMargin - 2 * radius);
      final randomY = radius + _random.nextDouble() * (size.y - 2 * radius);
      randomPosition = Vector2(randomX, randomY);
      attempts++;
    } while (_isPositionOccupied(randomPosition, minDistance) &&
        attempts < maxAttempts);

    if (attempts < maxAttempts) {
      _occupiedPositions.add(randomPosition);
      marble.add(MoveToEffect(randomPosition, LinearEffectController(1.0)));
    } else {
      // If can't find position, place at a fallback
      final fallbackX =
          leftMargin + radius + (size.x - leftMargin - 2 * radius) / 2;
      final fallbackY = radius + (size.y - 2 * radius) / 2;
      randomPosition = Vector2(fallbackX, fallbackY);
      _occupiedPositions.add(randomPosition);
      marble.add(MoveToEffect(randomPosition, LinearEffectController(1.0)));
    }
  }

  bool _isPositionOccupied(Vector2 position, double minDistance) {
    for (final occupied in _occupiedPositions) {
      if ((position - occupied).length < minDistance) {
        return true;
      }
    }
    return false;
  }

  /// Check proximity and create/merge groups when marble is dragged
  void checkProximityAndGroup(Marble draggedMarble) {
    if (draggedMarble.currentGroup != null) {
      // Marble is already in a group, skip proximity check
      return;
    }

    // Find nearby marbles or groups
    final nearbyMarble = _findNearbyMarble(draggedMarble);
    final nearbyGroup = _findNearbyGroup(draggedMarble);

    if (nearbyGroup != null && canMergeIntoGroup(draggedMarble, nearbyGroup)) {
      // Merge into existing group
      nearbyGroup.addMarble(draggedMarble);
    } else if (nearbyMarble != null && nearbyMarble.currentGroup == null) {
      // Create new group with two marbles
      createNewGroup(draggedMarble, nearbyMarble);
    }
  }

  /// Find a nearby marble within proximity threshold
  Marble? _findNearbyMarble(Marble marble) {
    for (final other in children.whereType<Marble>()) {
      if (other == marble) continue;
      if (other.currentGroup != null) continue; // Skip grouped marbles

      final distance = (marble.position - other.position).length;
      if (distance <= proximityThreshold) {
        return other;
      }
    }
    return null;
  }

  /// Find a nearby group within proximity threshold
  MarbleGroup? _findNearbyGroup(Marble marble) {
    for (final group in groups) {
      // Check distance to any marble in the group
      for (final groupMarble in group.marbles) {
        final distance = (marble.position - groupMarble.position).length;
        if (distance <= proximityThreshold) {
          return group;
        }
      }
    }
    return null;
  }

  /// Create a new group with two marbles
  void createNewGroup(Marble marble1, Marble marble2) {
    // All groups use soft red color
    const groupColor = Color(0xFFEF5350); // Soft red

    final newGroup = MarbleGroup(
      groupColor: groupColor,
      proximityThreshold: proximityThreshold,
    );

    groups.add(newGroup);
    add(newGroup);

    newGroup.addMarble(marble1);
    newGroup.addMarble(marble2);
  }

  /// Check if a marble can merge into a group
  bool canMergeIntoGroup(Marble marble, MarbleGroup group) {
    // Don't allow merging if marble is already in a group
    if (marble.currentGroup != null) return false;

    // Don't allow merging if group is submitted
    if (group.isSubmitted) return false;

    return true;
  }

  /// Validate answer when "Check Answer" button is clicked
  void onCheckAnswerClicked() {
    final isCorrect = validateSubmitAreas();

    if (isCorrect) {
      Get.log('Correct! All groups have the right size.');
      // Show celebration animation
      // Move to next problem
      onAnswerValidated?.call(true);
    } else {
      Get.log('Incorrect. Try again!');
      // Return groups to play area
      returnGroupsToPlayArea();
      onAnswerValidated?.call(false);
    }
  }

  /// Validate that all 3 submit areas have groups of the correct size
  bool validateSubmitAreas() {
    // Check that all 3 areas have a group
    for (final area in submitAreas) {
      if (area.assignedGroup == null) {
        return false;
      }

      // Check that each group has the correct number of marbles
      if (area.assignedGroup!.marbles.length != targetGroupSize) {
        return false;
      }
    }

    return true;
  }

  /// Return groups to play area when answer is incorrect
  void returnGroupsToPlayArea() {
    for (final area in submitAreas) {
      if (area.assignedGroup != null) {
        final group = area.assignedGroup!;
        group.returnToPlayArea();
        area.removeGroup();

        // Animate marbles back to random positions
        for (final marble in group.marbles) {
          _animateMarbleToRandom(marble);
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check for proximity grouping when marbles are being dragged
    for (final marble in children.whereType<Marble>()) {
      if (marble.isDragging) {
        checkProximityAndGroup(marble);
      }
    }

    // Check for group-to-submit-area interactions
    for (final group in groups) {
      if (!group.isSubmitted) {
        // Check if group is being dragged over a submit area
        for (final area in submitAreas) {
          if (area.containsGroup(group)) {
            area.highlightArea(true);
          } else {
            area.highlightArea(false);
          }
        }
      }
    }
  }

  /// Check if answer is correct
  /// Returns true if all 3 submit areas have groups with correct count
  bool checkAnswer() {
    // Check if all 3 areas have groups
    for (final area in submitAreas) {
      if (area.assignedGroup == null) {
        return false; // Missing group in one or more areas
      }
    }

    // Check if all groups have the correct count (targetGroupSize)
    for (final area in submitAreas) {
      final group = area.assignedGroup!;
      if (group.marbles.length != targetGroupSize) {
        return false; // Wrong count
      }
    }

    return true; // All correct!
  }

  /// Shake wrong groups to indicate error
  void shakeWrongGroups() {
    for (final area in submitAreas) {
      if (area.assignedGroup != null) {
        final group = area.assignedGroup!;
        // Shake if count is wrong
        if (group.marbles.length != targetGroupSize) {
          _shakeGroup(group);
        }
      }
    }
  }

  /// Apply continuous shake animation to a group
  void _shakeGroup(MarbleGroup group) {
    // Add repeating shake effect to each marble in the group
    for (final marble in group.marbles) {
      // Remove any existing shake effects
      marble.children.whereType<SequenceEffect>().forEach((effect) {
        effect.removeFromParent();
      });

      // Add continuous shake effect
      final shakeEffect = SequenceEffect([
        MoveEffect.by(Vector2(3, 0), EffectController(duration: 0.1)),
        MoveEffect.by(Vector2(-6, 0), EffectController(duration: 0.1)),
        MoveEffect.by(Vector2(6, 0), EffectController(duration: 0.1)),
        MoveEffect.by(Vector2(-3, 0), EffectController(duration: 0.1)),
      ], repeatCount: 3); // Repeat 3 times

      marble.add(shakeEffect);
    }
  }

  /// Stop shaking all groups
  void stopShakingGroups() {
    for (final area in submitAreas) {
      if (area.assignedGroup != null) {
        final group = area.assignedGroup!;
        for (final marble in group.marbles) {
          // Remove shake effects
          marble.children.whereType<SequenceEffect>().toList().forEach((
            effect,
          ) {
            effect.removeFromParent();
          });
        }
      }
    }
  }
}
