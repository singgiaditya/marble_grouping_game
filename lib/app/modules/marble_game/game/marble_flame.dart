import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/submit_area.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/services/game_validation_service.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/services/grouping_service.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/services/marble_animation_service.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/services/marble_positioning_service.dart';

/// Main game class for the marble grouping game
class MarbleFlame extends FlameGame {
  // Services
  late final MarblePositioningService _positioningService;
  late final MarbleAnimationService _animationService;
  late final GroupingService _groupingService;
  late final GameValidationService _validationService;

  // Grouping system
  final List<MarbleGroup> groups = [];

  // Game configuration
  late int targetGroupSize; // The result of division (e.g., 12 ÷ 3 = 4)
  late int totalMarbles; // result × 3

  // Submit areas
  late final List<SubmitArea> submitAreas;

  // Validation callback
  Function(bool isCorrect)? onAnswerValidated;

  // Reset state - prevents interaction during reset animation
  bool isResetting = false;

  @override
  Color backgroundColor() => const Color(0x00000000);

  double marbleRadius() => GameConstants.defaultMarbleRadius;

  Vector2 areaSize() => Vector2(60, (size.y / 3) - 20);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    // Initialize services
    _positioningService = MarblePositioningService(
      gameSize: size,
      marbleRadius: marbleRadius(),
    );

    _animationService = MarbleAnimationService(
      gameComponent: this,
      gameSize: size,
      marbleRadius: marbleRadius(),
      positioningService: _positioningService,
    );

    _groupingService = GroupingService(
      groups: groups,
      proximityThreshold: GameConstants.proximityThreshold,
    );

    // Ensure camera is centered
    camera.viewfinder.position = Vector2(size.x / 2, size.y / 2);
    camera.viewfinder.anchor = Anchor.center;

    // Create submit areas
    _initializeSubmitAreas();

    // Initialize validation service after submit areas are created
    _validationService = GameValidationService(
      targetGroupSize: targetGroupSize,
      submitAreas: submitAreas,
    );
  }

  /// Initialize the three submit areas
  void _initializeSubmitAreas() {
    final area1 = SubmitArea()
      ..size = areaSize()
      ..position = Vector2(0, 0);

    final area2 =
        SubmitArea(bgColor: MyColor.area2, shadowColor: MyColor.area2Shadow)
          ..size = areaSize()
          ..position = Vector2(0, area1.position.y + areaSize().y + 20);

    final area3 =
        SubmitArea(bgColor: MyColor.area3, shadowColor: MyColor.area3Shadow)
          ..size = areaSize()
          ..position = Vector2(0, area2.position.y + areaSize().y + 20);

    submitAreas = [area1, area2, area3];
    addAll(submitAreas);
  }

  /// Update marble count with animation
  void updateMarbles(int count) {
    _positioningService.clearOccupiedPositions();

    final currentMarbles = children.whereType<Marble>().toList();

    _animationService.updateMarblesWithAnimation(
      currentMarbles: currentMarbles,
      groups: groups,
      targetCount: count,
      onCenterAnimationComplete: (targetCount) {
        _handleCenterAnimationComplete(targetCount);
      },
    );

    // Update total marbles for validation
    targetGroupSize = count ~/ 3;
    totalMarbles = count;
  }

  /// Handle completion of center animation
  void _handleCenterAnimationComplete(int targetCount) {
    final currentMarbles = children.whereType<Marble>().toList();
    final center = _animationService.centerPosition;

    // Animate existing marbles to center
    _animationService.animateMarblesToCenter(currentMarbles);

    // Wait for center animation, then adjust count
    add(
      TimerComponent(
        period: GameConstants.moveToCenterDuration + 0.1,
        removeOnFinish: true,
        onTick: () {
          _adjustMarbleCount(targetCount, center);
        },
      ),
    );
  }

  /// Adjust marble count (add or remove marbles)
  void _adjustMarbleCount(int targetCount, Vector2 center) {
    final currentMarbles = children.whereType<Marble>().toList();

    // Remove excess marbles if count decreased
    if (currentMarbles.length > targetCount) {
      for (int i = targetCount; i < currentMarbles.length; i++) {
        remove(currentMarbles[i]);
      }
    } else if (currentMarbles.length < targetCount) {
      // Add new marbles at center
      for (int i = currentMarbles.length; i < targetCount; i++) {
        final marble = Marble(radius: marbleRadius())..position = center;
        add(marble);
      }
    }
  }

  /// Detach all marbles from their groups with staggered animation
  void detachAllGroups() {
    _animationService.detachAllGroups(groups);
  }

  /// Clear all submit areas (unsubmit all groups)
  void clearAllSubmitAreas() {
    _groupingService.clearAllSubmitAreas(submitAreas);
  }

  /// Animate all marbles to center and adjust count
  void animateMarblesToCenter(int count) {
    final marbles = children.whereType<Marble>().toList();
    _animationService.animateMarblesToCenter(marbles);

    // Wait for animation, then adjust count
    add(
      TimerComponent(
        period: GameConstants.moveToCenterDuration + 0.1,
        removeOnFinish: true,
        onTick: () {
          _adjustMarbleCount(count, _animationService.centerPosition);
        },
      ),
    );
  }

  /// Spread marbles from center to random positions
  void spreadMarbles(int count) {
    add(
      TimerComponent(
        period: 0.05,
        removeOnFinish: true,
        onTick: () {
          final marbles = children.whereType<Marble>().toList();
          _animationService.spreadMarbles(marbles);
        },
      ),
    );
  }

  /// Check proximity and create/merge groups when marble is dragged
  void checkProximityAndGroup(Marble draggedMarble) {
    final allMarbles = children.whereType<Marble>().toList();
    _groupingService.checkProximityAndGroup(
      draggedMarble,
      allMarbles,
      onGroupCreated: (group) => add(group),
    );
  }

  /// Create a new group with two marbles
  MarbleGroup createNewGroup(Marble marble1, Marble marble2) {
    final newGroup = _groupingService.createNewGroup(
      marble1,
      marble2,
      onGroupCreated: (group) => add(group),
    );
    return newGroup;
  }

  /// Check if a marble can merge into a group
  bool canMergeIntoGroup(Marble marble, MarbleGroup group) {
    return _groupingService.canMergeIntoGroup(marble, group);
  }

  /// Validate answer when "Check Answer" button is clicked
  void onCheckAnswerClicked() {
    final isCorrect = _validationService.validateSubmitAreas();

    if (isCorrect) {
      Get.log('Correct! All groups have the right size.');
      onAnswerValidated?.call(true);
    } else {
      Get.log('Incorrect. Try again!');
      returnGroupsToPlayArea();
      onAnswerValidated?.call(false);
    }
  }

  /// Validate that all 3 submit areas have groups of the correct size
  bool validateSubmitAreas() {
    return _validationService.validateSubmitAreas();
  }

  /// Return groups to play area when answer is incorrect
  void returnGroupsToPlayArea() {
    for (final area in submitAreas) {
      if (area.assignedGroup != null) {
        final group = area.assignedGroup!;
        group.returnToPlayArea();
        area.removeGroup();

        // Animate marbles back to random positions
        _animationService.returnMarblesToPlayArea(group.marbles);
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
        _updateSubmitAreaHighlights(group);
      }
    }
  }

  /// Update submit area highlights based on group position
  void _updateSubmitAreaHighlights(MarbleGroup group) {
    for (final area in submitAreas) {
      if (area.containsGroup(group)) {
        area.highlightArea(true);
      } else {
        area.highlightArea(false);
      }
    }
  }

  /// Check if answer is correct
  bool checkAnswer() {
    return _validationService.checkAnswer();
  }

  /// Shake wrong groups to indicate error
  void shakeWrongGroups() {
    _validationService.shakeWrongGroups();
  }

  /// Stop shaking all groups
  void stopShakingGroups() {
    _validationService.stopShakingGroups();
  }
}
