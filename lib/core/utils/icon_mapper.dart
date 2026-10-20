import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Maps stored icon key strings to Lucide / Material icons.
abstract final class IconMapper {
  static IconData fromKey(String? key) {
    switch (key) {
      case 'wallet':
        return LucideIcons.wallet;
      case 'landmark':
        return LucideIcons.landmark;
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'utensils':
        return LucideIcons.utensils;
      case 'car':
        return LucideIcons.car;
      case 'shopping-bag':
        return LucideIcons.shoppingBag;
      case 'zap':
        return LucideIcons.zap;
      case 'clapperboard':
        return LucideIcons.clapperboard;
      case 'briefcase':
        return LucideIcons.briefcase;
      case 'laptop':
        return LucideIcons.laptop;
      case 'trending-up':
        return LucideIcons.trendingUp;
      case 'arrow-left-right':
        return LucideIcons.arrowLeftRight;
      case 'piggy-bank':
        return LucideIcons.piggyBank;
      case 'credit-card':
        return LucideIcons.creditCard;
      default:
        return LucideIcons.circle;
    }
  }

  static Color colorFromHex(String? hex, {Color fallback = const Color(0xFF64748B)}) {
    if (hex == null || hex.isEmpty) return fallback;
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    try {
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
