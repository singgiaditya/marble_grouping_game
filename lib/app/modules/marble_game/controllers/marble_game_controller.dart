import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/utils/equation_generator.dart';
import 'package:marble_grouping_game/app/data/models/equation_model.dart';
import 'dart:async';
import 'package:marble_grouping_game/app/modules/marble_game/game/marble_flame.dart';
import 'package:marble_grouping_game/app/modules/marble_game/widgets/result_overlay.dart';

class MarbleGameController extends GetxController {
  final EquationGenerator equationGenerator = EquationGenerator();

  Rx<EquationModel> currentEquation = EquationModel(a: 0, b: 1).obs;
  RxBool isAnimating = false.obs;
  MarbleFlame? game;
  Timer? _animationTimer;
  final int _animationDuration = 2000; // total animation duration in ms
  final int _animationStep = 100; // update every 100ms

  @override
  void onClose() {
    _animationTimer?.cancel();
    super.onClose();
  }

  /// Call this after game is ready to start first equation
  void initializeGame() {
    if (game != null) {
      generateNewEquation();
    }
  }

  void generateNewEquation() {
    if (isAnimating.value) return;

    isAnimating.value = true;
    final newEquation = equationGenerator.generateEquation();

    // Lock marble interactions during reset
    game?.isResetting = true;

    // Clear all submit areas first (unsubmit groups)
    game?.clearAllSubmitAreas();

    // Detach all groups
    game?.detachAllGroups();

    // After detach completes (~0.7s), animate to center
    Future.delayed(Duration(milliseconds: 700), () {
      game?.animateMarblesToCenter(newEquation.result * 3);
    });

    // Step 3: Start equation randomize animation
    int elapsed = 0;
    _animationTimer = Timer.periodic(Duration(milliseconds: _animationStep), (
      timer,
    ) {
      elapsed += _animationStep;

      if (elapsed >= _animationDuration) {
        // animation done, set actual equation
        currentEquation.value = newEquation;
        isAnimating.value = false;

        // Update target group size for validation
        game?.targetGroupSize = newEquation.result;

        // Step 4: Spread marbles when animation completes
        game?.spreadMarbles(newEquation.result * 3);

        // Unlock marble interactions after spread completes (~1s)
        Future.delayed(Duration(milliseconds: 1100), () {
          game?.isResetting = false;
        });

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

  /// Check answer and show result overlay
  void checkAnswer() {
    if (game == null) return;

    // Prevent checking during reset
    if (game!.isResetting || isAnimating.value) return;

    final isCorrect = game!.checkAnswer();

    // Show result overlay
    _showResultOverlay(isCorrect);
  }

  /// Show result overlay with animation
  void _showResultOverlay(bool isCorrect) {
    Get.dialog(
      ResultOverlay(
        isCorrect: isCorrect,
        onContinue: () {
          Get.back(); // Close overlay

          if (isCorrect) {
            // Generate new equation on correct answer
            generateNewEquation();
          } else {
            // Shake wrong groups AFTER overlay closes (more visible)
            Future.delayed(Duration(milliseconds: 300), () {
              game?.shakeWrongGroups();
            });
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  int _getRandomNumber(int min, int max) {
    return min + (DateTime.now().millisecondsSinceEpoch % (max - min + 1));
  }
}
