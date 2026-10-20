import 'package:flutter/material.dart';

import 'glass.dart';

/// Solid menu/dropdown colors so lists are readable on glass backgrounds.
ThemeData formMenusTheme(BuildContext context) {
  final base = Theme.of(context);
  final surface = Glass.modalSurface(context);
  final onSurface = base.colorScheme.onSurface;

  return base.copyWith(
    canvasColor: surface,
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(surface),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(12),
        shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.45)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(surface),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(12),
      ),
      textStyle: base.textTheme.bodyLarge?.copyWith(color: onSurface),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      textStyle: base.textTheme.bodyMedium?.copyWith(color: onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
