import 'dart:ui';

import 'package:flutter/material.dart';

/// Glassmorphism tokens & building blocks for SakuKu.
abstract final class Glass {
  static const double blurSigma = 18;
  static const double radius = 22;
  static const double thinRadius = 16;

  static Color fill(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.55);
  }

  static Color border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.75);
  }

  static Color highlight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.35);
  }

  /// Bottom / top chrome — darker than cards so it separates from content.
  static Color barFill(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF07121A).withValues(alpha: 0.82)
        : const Color(0xFFF0FDFA).withValues(alpha: 0.78);
  }

  static Color barBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return isDark
        ? primary.withValues(alpha: 0.35)
        : primary.withValues(alpha: 0.22);
  }

  /// Opaque surface for modals — readable text, no stacked blur with barrier.
  static Color modalSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC);
  }

  static Color modalBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
  }

  static List<BoxShadow> softShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ];
  }
}

/// Soft mesh gradient that sits behind frosted panels.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF0B1220),
                      Color(0xFF10241F),
                      Color(0xFF0F172A),
                    ]
                  : const [
                      Color(0xFFE8F7F4),
                      Color(0xFFF3F8FF),
                      Color(0xFFEEF6F3),
                    ],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: _Blob(
            size: 260,
            color: primary.withValues(alpha: isDark ? 0.28 : 0.22),
          ),
        ),
        Positioned(
          top: 180,
          left: -90,
          child: _Blob(
            size: 220,
            color: const Color(0xFF38BDF8)
                .withValues(alpha: isDark ? 0.18 : 0.16),
          ),
        ),
        Positioned(
          bottom: 40,
          right: -60,
          child: _Blob(
            size: 240,
            color: const Color(0xFF34D399)
                .withValues(alpha: isDark ? 0.16 : 0.14),
          ),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

/// Frosted glass panel (card / sheet / chip container).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.tint,
    this.blur = Glass.blurSigma,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? tint;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(Glass.radius);
    final content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: tint ?? Glass.fill(context),
            border: Border.all(color: Glass.border(context), width: 1.1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Glass.highlight(context),
                (tint ?? Glass.fill(context)).withValues(alpha: 0.05),
              ],
            ),
            boxShadow: Glass.softShadow(context),
          ),
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );

    final wrapped = margin == null
        ? content
        : Padding(padding: margin!, child: content);

    if (onTap == null) return wrapped;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: wrapped,
      ),
    );
  }
}

/// Frosted bottom / top bars (deeper tint than content cards).
/// Bottom sheet shell with solid surface (use instead of frosted BackdropFilter).
class GlassSheetShell extends StatelessWidget {
  const GlassSheetShell({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Material(
        color: Glass.modalSurface(context),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Glass.modalBorder(context)),
              left: BorderSide(color: Glass.modalBorder(context)),
              right: BorderSide(color: Glass.modalBorder(context)),
            ),
          ),
          child: padding == null ? child : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}

class GlassBar extends StatelessWidget {
  const GlassBar({
    super.key,
    required this.child,
    this.height,
    this.padding,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Glass.barFill(context),
            border: Border(
              top: BorderSide(color: Glass.barBorder(context), width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
