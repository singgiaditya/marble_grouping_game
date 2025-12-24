import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';
import 'package:get/get.dart';
import 'package:marble_grouping_game/app/modules/marble_game/controllers/marble_game_controller.dart';
import 'package:flame/effects.dart';

class MarbleFlame extends FlameGame {
  final Random _random = Random();

  @override
  Color backgroundColor() => const Color(0xff000000);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    final controller = Get.find<MarbleGameController>();
    final count = controller.currentEquation.value.result * 3;
    final center = Vector2(size.x / 2, size.y / 2);
    for (int i = 0; i < count; i++) {
      final marble = Marble()..position = center;
      add(marble);
      _animateMarbleToRandom(marble);
    }
  }

  void updateMarbles(int count) {
    // Animate all marbles to center
    _animateAllMarblesToCenter();
    // After animation, update marbles
    Future.delayed(const Duration(seconds: 3), () {
      removeWhere((component) => component is Marble);
      final center = Vector2(size.x / 2, size.y / 2);
      for (int i = 0; i < count; i++) {
        final marble = Marble()..position = center;
        add(marble);
        _animateMarbleToRandom(marble);
      }
    });
  }

  void _animateAllMarblesToCenter() {
    final center = Vector2(size.x / 2, size.y / 2);
    for (final component in children) {
      if (component is Marble) {
        component.add(
          MoveToEffect(
            center,
            LinearEffectController(1.0),
          ),
        );
      }
    }
  }

  void _animateMarbleToRandom(Marble marble) {
    final randomX = _random.nextDouble() * size.x;
    final randomY = _random.nextDouble() * size.y;
    final randomPosition = Vector2(randomX, randomY);
    marble.add(
      MoveToEffect(
        randomPosition,
        LinearEffectController(1.0),
      ),
    );
  }
}
