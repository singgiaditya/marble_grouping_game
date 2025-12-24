import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/utils/equation_generator.dart';
import 'package:marble_grouping_game/app/data/models/equation_model.dart';
import 'dart:async';

class MarbleGameController extends GetxController {
  final EquationGenerator equationGenerator = EquationGenerator();
  
  Rx<EquationModel> currentEquation = EquationModel(a: 0, b: 1).obs;
  RxBool isAnimating = false.obs;
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

  int _getRandomNumber(int min, int max) {
    return min + (DateTime.now().millisecondsSinceEpoch % (max - min + 1));
  }
}
