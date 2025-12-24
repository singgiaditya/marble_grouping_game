import 'dart:math';

import 'package:marble_grouping_game/app/data/models/equation_model.dart';

class EquationGenerator {
  EquationGenerator({this.maxResult = 10, this.maxB = 30, this.maxA = 30});

  final int maxResult;
  final int maxB;
  final int maxA;

  final Random _random = Random();

  EquationModel generateEquation() {
    int a, b, result;

    do {
      result = _random.nextInt(maxResult - 1) + 2; // result from 2 to maxResult
      b = _random.nextInt(maxB - 1) + 2; // result from 2 to maxResult
      a = result * b;
    } while (a > maxA);

    return EquationModel(a: a, b: b);
  }
}
