import 'package:flutter/material.dart';

/// Shared durations / curves for SakuKu navigation motion.
abstract final class AppMotion {
  static const Duration page = Duration(milliseconds: 380);
  static const Duration quick = Duration(milliseconds: 240);
  static const Curve curve = Curves.easeOutCubic;
}

/// Fade + slight horizontal slide for tab / section switches.
class FadeSlideSwitcher extends StatelessWidget {
  const FadeSlideSwitcher({
    super.key,
    required this.child,
    this.duration = AppMotion.page,
    this.slideOffset = 0.04,
  });

  final Widget child;
  final Duration duration;
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppMotion.curve,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: Offset(slideOffset, 0.03),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: AppMotion.curve));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: child,
    );
  }
}

/// Keeps [PageView] children alive when off-screen.
class KeepAlivePage extends StatefulWidget {
  const KeepAlivePage({super.key, required this.child});

  final Widget child;

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Soft fade-up transition for Material routes (sheets already custom).
class SoftFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const SoftFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
