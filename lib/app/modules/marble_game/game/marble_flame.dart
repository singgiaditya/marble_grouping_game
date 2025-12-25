import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/submit_area.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:flame/effects.dart';

class MarbleFlame extends FlameGame {
  final Random _random = Random();
  final List<Vector2> _occupiedPositions = [];

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
    // Spawn 1 marble at center for initial load
    final marble = Marble(radius: marbleRadius())
      ..position = Vector2(size.x / 2, size.y / 2);
    add(marble);
    // Do not animate to random initially
    
    final SubmitArea area1 = SubmitArea()
      ..size = areaSize()
      ..position = Vector2(0, 0);

    final SubmitArea area2 = SubmitArea(bgColor: MyColor.area2, shadowColor: MyColor.area2Shadow)
      ..size = areaSize()
      ..position = Vector2(0, area1.position.y + areaSize().y + 20);

    final SubmitArea area3 = SubmitArea(bgColor: MyColor.area3, shadowColor: MyColor.area3Shadow)
      ..size = areaSize()
      ..position = Vector2(0, area2.position.y + areaSize().y + 20);
    addAll([area1, area2, area3]);
  }

  void updateMarbles(int count) {
    _occupiedPositions.clear();
    final marbles = children.whereType<Marble>().toList();
    // If count changed, adjust
    if (marbles.length > count) {
      // Remove excess
      for (int i = count; i < marbles.length; i++) {
        remove(marbles[i]);
      }
      marbles.removeRange(count, marbles.length);
    } else if (marbles.length < count) {
      // Add more at center
      for (int i = marbles.length; i < count; i++) {
        final marble = Marble(radius: marbleRadius())
          ..position = Vector2(size.x / 2, size.y / 2);
        add(marble);
        marbles.add(marble);
      }
    }
    // Now animate all to random
    for (final marble in marbles) {
      _animateMarbleToRandom(marble);
    }
  }

  void animateAllMarblesToCenter() {
    final center = Vector2(size.x / 2, size.y / 2); // Screen center
    Get.log('Animating marbles to center at $center');
    for (final component in children) {
      if (component is Marble) {
        component.add(MoveToEffect(center, LinearEffectController(1.0)));
      }
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
}
