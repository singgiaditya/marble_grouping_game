import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble_group.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/constants/game_constants.dart';

/// Service responsible for marble grouping logic
class GroupingService {
  final List<MarbleGroup> groups;
  final double proximityThreshold;

  GroupingService({
    required this.groups,
    this.proximityThreshold = GameConstants.proximityThreshold,
  });

  /// Check proximity and create/merge groups when marble is dragged
  void checkProximityAndGroup(
    Marble draggedMarble,
    List<Marble> allMarbles, {
    required Function(MarbleGroup) onGroupCreated,
  }) {
    if (draggedMarble.currentGroup != null) {
      // Marble is already in a group, skip proximity check
      return;
    }

    // Find nearby marbles or groups
    final nearbyMarble = _findNearbyMarble(draggedMarble, allMarbles);
    final nearbyGroup = _findNearbyGroup(draggedMarble);

    if (nearbyGroup != null && canMergeIntoGroup(draggedMarble, nearbyGroup)) {
      // Merge into existing group
      nearbyGroup.addMarble(draggedMarble);
    } else if (nearbyMarble != null && nearbyMarble.currentGroup == null) {
      // Create new group with two marbles
      createNewGroup(
        draggedMarble,
        nearbyMarble,
        onGroupCreated: onGroupCreated,
      );
    }
  }

  /// Find a nearby marble within proximity threshold
  Marble? _findNearbyMarble(Marble marble, List<Marble> allMarbles) {
    for (final other in allMarbles) {
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
  /// Callback onGroupCreated is called to add group to game component tree
  MarbleGroup createNewGroup(
    Marble marble1,
    Marble marble2, {
    required Function(MarbleGroup) onGroupCreated,
  }) {
    // All groups use soft red color
    const groupColor = Color(0xFFEF5350); // Soft red

    final newGroup = MarbleGroup(
      groupColor: groupColor,
      proximityThreshold: proximityThreshold,
    );

    groups.add(newGroup);

    // CRITICAL: Add group to game component tree via callback
    onGroupCreated(newGroup);

    newGroup.addMarble(marble1);
    newGroup.addMarble(marble2);

    return newGroup;
  }

  /// Check if a marble can merge into a group
  bool canMergeIntoGroup(Marble marble, MarbleGroup group) {
    // Don't allow merging if marble is already in a group
    if (marble.currentGroup != null) return false;

    // Don't allow merging if group is submitted
    if (group.isSubmitted) return false;

    return true;
  }

  /// Clear all submit areas (unsubmit all groups)
  void clearAllSubmitAreas(dynamic submitAreas) {
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
}
