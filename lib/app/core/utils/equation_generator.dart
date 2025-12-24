import 'dart:math';

import 'package:marble_grouping_game/app/data/models/equation_model.dart';

class EquationGenerator {
  EquationGenerator({this.maxResult = 10, this.maxB = 30, this.maxA = 100});

  final int maxResult;
  final int maxB;
  final int maxA;

  final Random _random = Random();

  EquationModel generateEquation() {
    int a, b, result;

    do {
      result = _random.nextInt(maxResult) + 1;
      b = _random.nextInt(maxB) + 2;
      a = result * b;
    } while (a > maxA);

    return EquationModel(a: a, b: b);
  }
}
