import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

mixin FadeInAnimationMixin {
  Widget fadeInFromTop(Widget child, {int? delay}) {
    return child
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: delay ?? 0),
        )
        .slideY(
          begin: -0.1,
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: delay ?? 0),
          curve: Curves.easeOut,
        );
  }

  Widget fadeIn(Widget child, {int? delay}) {
    return child.animate().fadeIn(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: delay ?? 0),
        );
  }

  List<Widget> staggeredFadeIn(List<Widget> children, {int delayStep = 50}) {
    return children.asMap().entries.map((entry) {
      return entry.value.animate().fadeIn(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: entry.key * delayStep),
          );
    }).toList();
  }
}
