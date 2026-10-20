import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Staggered fade + scale entrance for dashboard / analytics cards.
extension EntranceAnimations on Widget {
  Widget entranceCard(int index, {double slideY = 0.06}) {
    return animate()
        .fadeIn(
          duration: 420.ms,
          delay: (55 * index).ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: slideY,
          end: 0,
          duration: 480.ms,
          delay: (55 * index).ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
          duration: 480.ms,
          delay: (55 * index).ms,
          curve: Curves.easeOutBack,
        );
  }
}
