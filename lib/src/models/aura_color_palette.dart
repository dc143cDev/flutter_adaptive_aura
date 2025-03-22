import 'package:flutter/material.dart';

/// Aura color palette class
class AuraColorPalette {
  /// Primary color
  final Color primary;

  /// Secondary color
  final Color secondary;

  /// Tertiary color
  final Color tertiary;

  /// Light color
  final Color light;

  /// Dark color
  final Color dark;

  /// Aura color palette constructor
  const AuraColorPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.light,
    required this.dark,
  });

  /// Create default palette
  factory AuraColorPalette.defaultPalette() {
    return const AuraColorPalette(
      primary: Color(0xFF6200EA),
      secondary: Color(0xFF3700B3),
      tertiary: Color(0xFF03DAC6),
      light: Color(0xFFBB86FC),
      dark: Color(0xFF121212),
    );
  }

  /// Create palette from single color
  factory AuraColorPalette.fromColor(Color color) {
    final HSLColor hsl = HSLColor.fromColor(color);

    // Secondary color (60 degrees in hue space)
    final HSLColor secondaryHsl = hsl.withHue((hsl.hue + 60) % 360);

    // Tertiary color (180 degrees in hue space)
    final HSLColor tertiaryHsl = hsl.withHue((hsl.hue + 180) % 360);

    // Light color
    final HSLColor lightHsl =
        hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0));

    // Dark color
    final HSLColor darkHsl =
        hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0));

    return AuraColorPalette(
      primary: color,
      secondary: secondaryHsl.toColor(),
      tertiary: tertiaryHsl.toColor(),
      light: lightHsl.toColor(),
      dark: darkHsl.toColor(),
    );
  }

  /// Create default background gradient
  LinearGradient createGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        dark,
        primary.withOpacity(0.7),
        secondary.withOpacity(0.5),
      ],
    );
  }

  /// Create custom background gradient
  LinearGradient createCustomGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [primary, secondary, tertiary],
      stops: stops,
    );
  }

  /// Create dark background gradient
  LinearGradient createDarkGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [dark, _darkenColor(primary, 0.2), _darkenColor(secondary, 0.2)],
      stops: stops,
    );
  }

  /// Darken color
  Color _darkenColor(Color color, double amount) {
    final HSLColor hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
