import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../adaptive_aura.dart';
import '../models/aura_color_palette.dart';
import 'blob_style_layer.dart';
import 'gradient_style_layer.dart';
import 'sunray_style_layer.dart';

/// Color characteristic enumeration
enum AuraColorCharacteristic {
  /// Vivid color series
  VIVID,

  /// Grayscale series
  GRAYSCALE,

  /// Dark color series
  DARK,

  /// Bright color series
  BRIGHT,

  /// Medium tone color series
  MEDIUM
}

/// Color palette analysis result
class ColorAnalysisResult {
  final AuraColorCharacteristic characteristic;
  final double brightness;
  final double vividness;

  ColorAnalysisResult({
    required this.characteristic,
    required this.brightness,
    required this.vividness,
  });
}

/// Class to hold background settings
class BackgroundSettings {
  final double lightColorWeight;
  final double primaryOpacity;
  final double secondaryOpacity;
  final double backgroundOpacity1;
  final double backgroundOpacity2;

  BackgroundSettings({
    required this.lightColorWeight,
    required this.primaryOpacity,
    required this.secondaryOpacity,
    required this.backgroundOpacity1,
    required this.backgroundOpacity2,
  });
}

/// Abstract class for Aura Style Layer
/// All Aura Style implementations must inherit from this class.
abstract class AuraStyleLayer extends StatelessWidget {
  /// Color palette
  final AuraColorPalette colorPalette;

  /// Animation controller
  final AnimationController animationController;

  /// Animation duration
  final Duration animationDuration;

  /// Blur strength (X-axis)
  final double blurStrengthX;

  /// Blur strength (Y-axis)
  final double blurStrengthY;

  /// Blur layer opacity
  final double blurLayerOpacity;

  /// Color intensity
  final double colorIntensity;

  /// Animation value (0.0 ~ 1.0)
  final double animationValue;

  /// Container size
  final Size containerSize;

  /// Variety value (0.0 ~ 1.0)
  /// Higher values generate more elements and complex effects
  final double variety;

  /// Color characteristic
  late final AuraColorCharacteristic colorCharacteristic;

  /// Color brightness (0.0 ~ 1.0)
  late final double colorBrightness;

  /// Color vividness (0.0 ~ 1.0)
  late final double colorVividness;

  /// Constructor
  AuraStyleLayer({
    super.key,
    required this.colorPalette,
    required this.animationController,
    required this.animationDuration,
    required this.blurStrengthX,
    required this.blurStrengthY,
    required this.blurLayerOpacity,
    required this.colorIntensity,
    this.animationValue = 0.0,
    this.containerSize = Size.zero,
    this.variety = 0.5,
  }) {
    // Analyze color palette
    final analysis = _analyzeColorPalette(colorPalette);
    colorCharacteristic = analysis.characteristic;
    colorBrightness = analysis.brightness;
    colorVividness = analysis.vividness;

    // Log output
    _logColorAnalysis();
  }

  /// Analyze color palette
  ColorAnalysisResult _analyzeColorPalette(AuraColorPalette palette) {
    // Analyze color brightness and vividness
    final primaryBrightness = _calculateColorBrightness(palette.primary);
    final secondaryBrightness = _calculateColorBrightness(palette.secondary);
    final tertiaryBrightness = _calculateColorBrightness(palette.tertiary);

    // Analyze color vividness
    final primaryVividness = _calculateColorVividness(palette.primary);
    final secondaryVividness = _calculateColorVividness(palette.secondary);
    final tertiaryVividness = _calculateColorVividness(palette.tertiary);

    // Calculate average brightness and vividness
    final avgBrightness =
        (primaryBrightness + secondaryBrightness + tertiaryBrightness) / 3;
    final avgVividness =
        (primaryVividness + secondaryVividness + tertiaryVividness) / 3;

    // Determine color characteristic
    AuraColorCharacteristic characteristic;
    if (avgVividness > 0.6) {
      characteristic = AuraColorCharacteristic.VIVID;
    } else if (avgVividness < 0.2) {
      characteristic = AuraColorCharacteristic.GRAYSCALE;
    } else if (avgBrightness < 0.3) {
      characteristic = AuraColorCharacteristic.DARK;
    } else if (avgBrightness > 0.7) {
      characteristic = AuraColorCharacteristic.BRIGHT;
    } else {
      characteristic = AuraColorCharacteristic.MEDIUM;
    }

    return ColorAnalysisResult(
      characteristic: characteristic,
      brightness: avgBrightness,
      vividness: avgVividness,
    );
  }

  /// Log color analysis results
  void _logColorAnalysis() {
    String characteristicName = '';
    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        characteristicName = 'Vivid color series';
        break;
      case AuraColorCharacteristic.GRAYSCALE:
        characteristicName = 'Grayscale series';
        break;
      case AuraColorCharacteristic.DARK:
        characteristicName = 'Dark color series';
        break;
      case AuraColorCharacteristic.BRIGHT:
        characteristicName = 'Bright color series';
        break;
      case AuraColorCharacteristic.MEDIUM:
        characteristicName = 'Medium tone color series';
        break;
    }

    debugPrint('🎨 Color palette analysis:');
    debugPrint(
        '  - Average brightness: ${colorBrightness.toStringAsFixed(2)} (0.0~1.0)');
    debugPrint(
        '  - Average vividness: ${colorVividness.toStringAsFixed(2)} (0.0~1.0)');
    debugPrint('  - Color characteristic: $characteristicName');

    // Output key color information
    final primaryBrightness = _calculateColorBrightness(colorPalette.primary);
    final secondaryBrightness =
        _calculateColorBrightness(colorPalette.secondary);
    final tertiaryBrightness = _calculateColorBrightness(colorPalette.tertiary);
    final primaryVividness = _calculateColorVividness(colorPalette.primary);
    final secondaryVividness = _calculateColorVividness(colorPalette.secondary);
    final tertiaryVividness = _calculateColorVividness(colorPalette.tertiary);

    debugPrint(
        '  - Primary: brightness=${primaryBrightness.toStringAsFixed(2)}, vividness=${primaryVividness.toStringAsFixed(2)}');
    debugPrint(
        '  - Secondary: brightness=${secondaryBrightness.toStringAsFixed(2)}, vividness=${secondaryVividness.toStringAsFixed(2)}');
    debugPrint(
        '  - Tertiary: brightness=${tertiaryBrightness.toStringAsFixed(2)}, vividness=${tertiaryVividness.toStringAsFixed(2)}');
  }

  /// Calculate color brightness (0.0 ~ 1.0)
  double _calculateColorBrightness(Color color) {
    // Calculate brightness from HSL model
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;

    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));

    // Calculate HSL lightness
    return (max + min) / 2;
  }

  /// Calculate color vividness (0.0 ~ 1.0)
  double _calculateColorVividness(Color color) {
    // Calculate saturation from HSL model
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;

    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final l = (max + min) / 2;

    // Calculate saturation
    if (max == min) {
      return 0; // Grayscale has saturation of 0
    } else {
      final d = max - min;
      return l > 0.5 ? d / (2 - max - min) : d / (max + min);
    }
  }

  /// Get background settings according to color characteristic
  BackgroundSettings getBackgroundSettingsForCharacteristic() {
    double lightColorWeight;
    double primaryOpacity;
    double secondaryOpacity;
    double backgroundOpacity1;
    double backgroundOpacity2;

    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        // Vivid series: Much brighter
        lightColorWeight = 0.85 + (colorBrightness * 0.15);
        primaryOpacity = 0.2;
        secondaryOpacity = 0.15;
        backgroundOpacity1 = 0.7;
        backgroundOpacity2 = 0.5;
        break;
      case AuraColorCharacteristic.GRAYSCALE:
        // Grayscale series: Much darker
        lightColorWeight = 0.2 + (colorBrightness * 0.2);
        primaryOpacity = 0.8;
        secondaryOpacity = 0.6;
        backgroundOpacity1 = 0.3;
        backgroundOpacity2 = 0.2;
        break;
      case AuraColorCharacteristic.DARK:
        // Dark color series: Darker
        lightColorWeight = 0.3 + (colorBrightness * 0.3);
        primaryOpacity = 0.7;
        secondaryOpacity = 0.5;
        backgroundOpacity1 = 0.4;
        backgroundOpacity2 = 0.25;
        break;
      case AuraColorCharacteristic.BRIGHT:
        // Bright color series: Brighter
        lightColorWeight = 0.7 + (colorBrightness * 0.2);
        primaryOpacity = 0.3;
        secondaryOpacity = 0.2;
        backgroundOpacity1 = 0.6;
        backgroundOpacity2 = 0.4;
        break;
      case AuraColorCharacteristic.MEDIUM:
      default:
        // Medium tone series: Medium level
        lightColorWeight =
            0.5 + (colorBrightness * 0.3) + (colorVividness * 0.2);
        primaryOpacity = 0.5;
        secondaryOpacity = 0.3;
        backgroundOpacity1 = 0.5;
        backgroundOpacity2 = 0.3;
        break;
    }

    return BackgroundSettings(
      lightColorWeight: lightColorWeight,
      primaryOpacity: primaryOpacity,
      secondaryOpacity: secondaryOpacity,
      backgroundOpacity1: backgroundOpacity1,
      backgroundOpacity2: backgroundOpacity2,
    );
  }

  /// Build style layer.
  /// Each implementation must override this method to define its own style.
  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder for size-related exception handling
    return LayoutBuilder(builder: (context, constraints) {
      // Check if the size is valid
      final hasValidSize =
          constraints.maxWidth > 0 && constraints.maxHeight > 0;

      if (!hasValidSize) {
        // If no valid size, return empty container
        return Container();
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          buildBackgroundLayer(),
          buildBlurLayer(),
          buildAuraLayer(),
        ],
      );
    });
  }

  /// Build background gradient layer.
  Widget buildBackgroundLayer();

  /// Build blur effect layer.
  Widget buildBlurLayer();

  /// Build aura effect layer.
  Widget buildAuraLayer();

  /// Create style layer according to style
  factory AuraStyleLayer.create({
    required AuraStyle style,
    required AuraColorPalette colorPalette,
    required AnimationController animationController,
    required Duration animationDuration,
    required double blurStrengthX,
    required double blurStrengthY,
    required double blurLayerOpacity,
    required double colorIntensity,
    double animationValue = 0.0,
    Size containerSize = Size.zero,
    double variety = 0.5,
  }) {
    switch (style) {
      case AuraStyle.BLOB:
        return BlobStyleLayer(
          colorPalette: colorPalette,
          animationController: animationController,
          animationDuration: animationDuration,
          blurStrengthX: blurStrengthX,
          blurStrengthY: blurStrengthY,
          blurLayerOpacity: blurLayerOpacity,
          colorIntensity: colorIntensity,
          animationValue: animationValue,
          containerSize: containerSize,
          variety: variety,
        );
      case AuraStyle.GRADIENT:
        return GradientStyleLayer(
          colorPalette: colorPalette,
          animationController: animationController,
          animationDuration: animationDuration,
          blurStrengthX: blurStrengthX,
          blurStrengthY: blurStrengthY,
          blurLayerOpacity: blurLayerOpacity,
          colorIntensity: colorIntensity,
          animationValue: animationValue,
          containerSize: containerSize,
          variety: variety,
        );
      case AuraStyle.SUNRAY: // New style
        return SunrayStyleLayer(
          colorPalette: colorPalette,
          animationController: animationController,
          animationDuration: animationDuration,
          blurStrengthX: blurStrengthX,
          blurStrengthY: blurStrengthY,
          blurLayerOpacity: blurLayerOpacity,
          colorIntensity: colorIntensity,
          animationValue: animationValue,
          containerSize: containerSize,
          variety: variety,
        );
    }
  }
}
