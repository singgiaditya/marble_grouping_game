import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marble_grouping_game/app/core/themes/my_color.dart';

class ResultOverlay extends StatelessWidget {
  final bool isCorrect;
  final VoidCallback onContinue;

  const ResultOverlay({
    super.key,
    required this.isCorrect,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      child: Center(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            width: Get.width * 0.8,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isCorrect ? MyColor.success : MyColor.area1Shadow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCorrect ? MyColor.darkSuccess : MyColor.area1,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCorrect ? MyColor.darkSuccess : MyColor.area1,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.bounceOut,
                  builder: (context, double value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Icon(
                    isCorrect ? Icons.star : Icons.close,
                    size: 100,
                    color: isCorrect ? MyColor.darkSuccess : MyColor.area1,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  isCorrect ? '🎉 Correct!' : '😢 Wrong!',
                  style: Get.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? MyColor.darkSuccess : MyColor.area1,
                  ),
                ),
                const SizedBox(height: 16),
                // Message
                Text(
                  isCorrect ? 'Great! Your answer is correct!' : 'Try again!',
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: isCorrect ? MyColor.darkSuccess : MyColor.area1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Button
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCorrect
                        ? MyColor.darkSuccess
                        : MyColor.area1,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 12,
                    shadowColor: isCorrect
                        ? MyColor.success
                        : MyColor.area1Shadow,
                  ),
                  child: Text(
                    isCorrect ? 'Continue' : 'Try Again',
                    style: Get.textTheme.titleLarge?.copyWith(
                      color: isCorrect ? MyColor.success : MyColor.area1Shadow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
