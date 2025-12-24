import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:marble_grouping_game/app/modules/marble_game/game/components/marble.dart';

class MarbleFlame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    add(Marble());
  }
}
