import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/utils/equation_generator.dart';
import 'package:marble_grouping_game/app/data/models/equation_model.dart';
import 'dart:async';
import 'package:marble_grouping_game/app/modules/marble_game/game/marble_flame.dart';

class MarbleGameController extends GetxController {
  final EquationGenerator equationGenerator = EquationGenerator();
  
  Rx<EquationModel> currentEquation = EquationModel(a: 0, b: 1).obs;
  RxBool isAnimating = false.obs;
  MarbleFlame? game;
  Timer? _animationTimer;
  final int _animationDuration = 3000; // total animation duration in ms
  final int _animationStep = 100; // update every 100ms

  @override
  void onInit() {
    super.onInit();
    generateNewEquation();
  }

  @override
  void onClose() {
    _animationTimer?.cancel();
    super.onClose();
  }

  void generateNewEquation() {
    if (isAnimating.value) return;
    
    game?.animateAllMarblesToCenter();
    isAnimating.value = true;
    final newEquation = equationGenerator.generateEquation();
    
    // start animation
    int elapsed = 0;
    _animationTimer = Timer.periodic(Duration(milliseconds: _animationStep), (timer) {
      elapsed += _animationStep;
      
      if (elapsed >= _animationDuration) {
        // animation done, set actual equation
        currentEquation.value = newEquation;
        isAnimating.value = false;
        // Update marbles after equation is set
        _updateMarbles();
        timer.cancel();
      } else {
        // Update with random numbers during animation
        currentEquation.value = EquationModel(
          a: _getRandomNumber(1, 100),
          b: _getRandomNumber(2, 30),
        );
      }
    });
  }

  void _updateMarbles() {
    game?.updateMarbles(currentEquation.value.result * 3);
  }

  int _getRandomNumber(int min, int max) {
    return min + (DateTime.now().millisecondsSinceEpoch % (max - min + 1));
  }
}
