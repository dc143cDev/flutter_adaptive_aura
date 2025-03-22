import 'package:flutter/material.dart';

/// 아우라 색상 팔레트 클래스
class AuraColorPalette {
  /// 주요 색상
  final Color primary;

  /// 보조 색상
  final Color secondary;

  /// 세 번째 색상
  final Color tertiary;

  /// 밝은 색상
  final Color light;

  /// 어두운 색상
  final Color dark;

  /// 아우라 색상 팔레트 생성자
  const AuraColorPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.light,
    required this.dark,
  });

  /// 기본 팔레트 생성
  factory AuraColorPalette.defaultPalette() {
    return const AuraColorPalette(
      primary: Color(0xFF6200EA),
      secondary: Color(0xFF3700B3),
      tertiary: Color(0xFF03DAC6),
      light: Color(0xFFBB86FC),
      dark: Color(0xFF121212),
    );
  }

  /// 단일 색상에서 팔레트 생성
  factory AuraColorPalette.fromColor(Color color) {
    final HSLColor hsl = HSLColor.fromColor(color);

    // 보조 색상 (색상환에서 60도 이동)
    final HSLColor secondaryHsl = hsl.withHue((hsl.hue + 60) % 360);

    // 세 번째 색상 (색상환에서 180도 이동)
    final HSLColor tertiaryHsl = hsl.withHue((hsl.hue + 180) % 360);

    // 밝은 색상
    final HSLColor lightHsl =
        hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0));

    // 어두운 색상
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

  /// 기본 배경 그라데이션 생성
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

  /// 커스텀 배경 그라데이션 생성
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

  /// 어두운 배경 그라데이션 생성
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

  /// 색상을 어둡게 만듭니다.
  Color _darkenColor(Color color, double amount) {
    final HSLColor hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
