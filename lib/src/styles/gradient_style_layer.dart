import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'aura_style_layer.dart';
import '../models/aura_color_palette.dart';

/// Class to store gradient point information
class _GradientPoint {
  final Color color;
  final Offset position;
  final double size;
  final double opacity;

  _GradientPoint({
    required this.color,
    required this.position,
    required this.size,
    required this.opacity,
  });
}

/// Class to store highlight point information
class _HighlightPoint {
  final Offset position;
  final double size;
  final double baseOpacity;
  final double
      varietyThreshold; // The variety threshold at which this highlight is activated

  _HighlightPoint({
    required this.position,
    required this.size,
    required this.baseOpacity,
    required this.varietyThreshold,
  });
}

/// Layer implementing Apple Music style full-color background
class GradientStyleLayer extends AuraStyleLayer {
  /// Animation state value (0.0 ~ 1.0)
  final double animationValue;

  /// Container size
  final Size containerSize;

  /// Gradient points cache
  late final List<_GradientPoint>? _gradientPointsCache;

  /// Last used container size
  late final Size? _lastContainerSize;

  /// Last used variety value
  late final double? _lastVariety;

  /// Last used animation value (rounded value)
  late final double? _lastAnimationValue;

  /// Random generator
  final _random = math.Random();

  /// Predefined highlight points
  late final List<_HighlightPoint> _highlightPoints;

  /// Constructor
  GradientStyleLayer({
    required super.colorPalette,
    required super.animationController,
    required super.animationDuration,
    required super.blurStrengthX,
    required super.blurStrengthY,
    required super.blurLayerOpacity,
    required super.colorIntensity,
    required super.variety,
    this.animationValue = 0.0,
    this.containerSize = Size.zero,
  }) {
    _initializeHighlightPoints();
  }

  /// Initialize highlight points
  void _initializeHighlightPoints() {
    _highlightPoints = [
      // Basic top highlight (always displayed)
      _HighlightPoint(
        position: Offset(
          containerSize.width * 0.5,
          -containerSize.width * 0.3, // Positioned higher
        ),
        size: containerSize.width * 0.8, // Reduced size
        baseOpacity: 0.45,
        varietyThreshold: 0.0,
      ),

      // Highlights displayed at variety >= 0.3
      _HighlightPoint(
        position: Offset(
          containerSize.width * 0.85,
          containerSize.height * 0.85,
        ),
        size: containerSize.width * 0.6,
        baseOpacity: 0.4,
        varietyThreshold: 0.3,
      ),

      // Middle area highlights (asymmetric placement)
      _HighlightPoint(
        position: Offset(
          containerSize.width * 0.25,
          containerSize.height * 0.45,
        ),
        size: containerSize.width * 0.5,
        baseOpacity: 0.35,
        varietyThreshold: 0.3,
      ),
      _HighlightPoint(
        position: Offset(
          containerSize.width * 0.75,
          containerSize.height * 0.35,
        ),
        size: containerSize.width * 0.45,
        baseOpacity: 0.35,
        varietyThreshold: 0.3,
      ),

      // Highlights displayed at variety >= 0.7
      _HighlightPoint(
        position: Offset(
          containerSize.width * 0.15,
          containerSize.height * 0.15,
        ),
        size: containerSize.width * 0.4,
        baseOpacity: 0.35,
        varietyThreshold: 0.7,
      ),
      _HighlightPoint(
        position: Offset(
          containerSize.width * 0.65,
          containerSize.height * 0.65,
        ),
        size: containerSize.width * 0.5,
        baseOpacity: 0.35,
        varietyThreshold: 0.7,
      ),
    ];
  }

  /// Calculate gradient point count based on variety value
  int get _effectiveGradientPointCount {
    // When variety is 0.0, use only 2 basic gradient points
    // When variety is 1.0, use up to 6 gradient points
    if (variety <= 0.0) return 2;
    return 2 + (4 * variety).round(); // 2 ~ 6 points (count reduced by half)
  }

  /// Generate gradient points
  List<_GradientPoint> _generateGradientPoints() {
    final points = <_GradientPoint>[];
    final pointCount = _effectiveGradientPointCount;

    // Basic gradient point (always included)
    points.add(_generateBaseGradientPoint());

    // Create additional gradient points if variety > 0
    if (variety > 0.0 && pointCount > 2) {
      // More diverse color palette based on variety
      final colors = <Color>[];

      // Adjust color palette composition according to color characteristic
      switch (colorCharacteristic) {
        case AuraColorCharacteristic.VIVID:
          // Vivid theme: Only vibrant colors, completely remove grayscale
          colors.add(colorPalette.primary);
          colors.add(colorPalette.secondary);
          colors.add(colorPalette.tertiary);

          // Add additional vibrant color mixes
          colors.add(
              Color.lerp(colorPalette.primary, colorPalette.secondary, 0.3)!);
          colors.add(
              Color.lerp(colorPalette.secondary, colorPalette.tertiary, 0.3)!);
          colors.add(
              Color.lerp(colorPalette.tertiary, colorPalette.primary, 0.3)!);

          // Add more diverse color mixes
          colors.add(
              Color.lerp(colorPalette.primary, colorPalette.secondary, 0.7)!);
          colors.add(
              Color.lerp(colorPalette.secondary, colorPalette.tertiary, 0.7)!);
          colors.add(
              Color.lerp(colorPalette.tertiary, colorPalette.primary, 0.7)!);

          // Add bright colors (lower weight) - adjust brightness instead of grayscale
          if (variety > 0.5) {
            // Adjust brightness with vibrant colors instead of white
            colors.add(
                Color.lerp(colorPalette.primary, colorPalette.secondary, 0.3)!);
            colors.add(Color.lerp(
                colorPalette.secondary, colorPalette.tertiary, 0.3)!);
            colors.add(
                Color.lerp(colorPalette.tertiary, colorPalette.primary, 0.3)!);
          }
          break;

        case AuraColorCharacteristic.GRAYSCALE:
          // Grayscale theme: Primarily grayscale colors
          colors.add(colorPalette.primary);
          colors.add(colorPalette.dark);
          colors.add(colorPalette.light);

          // Add additional grayscale mixes
          colors.add(Color.lerp(colorPalette.primary, colorPalette.dark, 0.5)!);
          colors
              .add(Color.lerp(colorPalette.primary, colorPalette.light, 0.5)!);

          // Add a touch of color (low weight)
          if (variety > 0.7) {
            colors.add(colorPalette.secondary.withOpacity(0.3));
          }
          break;

        case AuraColorCharacteristic.DARK:
          // Dark theme: Primarily dark colors
          colors.add(colorPalette.primary);
          colors.add(colorPalette.dark);
          colors.add(colorPalette.secondary);

          // Add additional dark color mixes
          colors.add(Color.lerp(colorPalette.primary, colorPalette.dark, 0.7)!);
          colors
              .add(Color.lerp(colorPalette.secondary, colorPalette.dark, 0.7)!);

          // Add a touch of bright colors (low weight)
          if (variety > 0.6) {
            colors.add(
                Color.lerp(colorPalette.primary, colorPalette.light, 0.2)!);
          }
          break;

        case AuraColorCharacteristic.BRIGHT:
          // Bright theme: Primarily bright colors
          colors.add(colorPalette.primary);
          colors.add(colorPalette.light);
          colors.add(colorPalette.secondary);

          // Add additional bright color mixes
          colors
              .add(Color.lerp(colorPalette.primary, colorPalette.light, 0.7)!);
          colors.add(
              Color.lerp(colorPalette.secondary, colorPalette.light, 0.7)!);

          // Add a touch of dark colors (low weight)
          if (variety > 0.6) {
            colors
                .add(Color.lerp(colorPalette.primary, colorPalette.dark, 0.2)!);
          }
          break;

        case AuraColorCharacteristic.MEDIUM:
          // Medium tone theme: Balanced color composition
          colors.add(colorPalette.primary);
          colors.add(colorPalette.secondary);
          colors.add(colorPalette.tertiary);
          colors.add(colorPalette.light);

          // Add more diverse color mixes as variety increases
          if (variety > 0.3) {
            colors.add(
                Color.lerp(colorPalette.primary, colorPalette.secondary, 0.5)!);
            colors.add(Color.lerp(
                colorPalette.secondary, colorPalette.tertiary, 0.5)!);
            colors.add(
                Color.lerp(colorPalette.tertiary, colorPalette.primary, 0.5)!);
          }

          if (variety > 0.6) {
            colors.add(
                Color.lerp(colorPalette.primary, colorPalette.light, 0.3)!);
            colors.add(
                Color.lerp(colorPalette.secondary, colorPalette.light, 0.4)!);
            colors.add(
                Color.lerp(colorPalette.tertiary, colorPalette.light, 0.5)!);
            colors
                .add(Color.lerp(colorPalette.primary, colorPalette.dark, 0.3)!);
            colors.add(
                Color.lerp(colorPalette.secondary, colorPalette.dark, 0.4)!);
          }
          break;
      }

      // Grid settings for more even distribution on screen
      // Place points to cover wider areas as there are fewer points
      final gridSize = math.sqrt(pointCount).ceil();
      final cellWidth = containerSize.width / gridSize;
      final cellHeight = containerSize.height / gridSize;

      for (int i = 1; i < pointCount; i++) {
        // Color selection (diverse color selection based on index)
        // Adjust color selection logic based on color characteristic
        int colorIndex;

        switch (colorCharacteristic) {
          case AuraColorCharacteristic.VIVID:
            // Vivid theme: Primarily vibrant colors (completely remove grayscale)
            // Always select vibrant colors
            colorIndex = _random.nextInt(colors.length);
            break;

          case AuraColorCharacteristic.GRAYSCALE:
            // Grayscale theme: Primarily grayscale colors
            colorIndex = _random.nextInt(colors.length);
            break;

          case AuraColorCharacteristic.DARK:
            // Dark theme: Primarily dark colors
            if (_random.nextDouble() < 0.7) {
              // 70% chance to select dark colors (indices 0-4)
              colorIndex = _random.nextInt(math.min(5, colors.length));
            } else {
              // 30% chance to select from remaining colors
              colorIndex = _random.nextInt(colors.length);
            }
            break;

          case AuraColorCharacteristic.BRIGHT:
            // Bright theme: Primarily bright colors
            if (_random.nextDouble() < 0.7) {
              // 70% chance to select bright colors (indices 0-4)
              colorIndex = _random.nextInt(math.min(5, colors.length));
            } else {
              // 30% chance to select from remaining colors
              colorIndex = _random.nextInt(colors.length);
            }
            break;

          case AuraColorCharacteristic.MEDIUM:
            // Medium tone theme: Variety determines color selection diversity
            if (_random.nextDouble() < variety * 0.8) {
              // Higher variety increases chance of using diverse colors
              colorIndex = _random.nextInt(colors.length);
            } else {
              // Select from basic colors (primary, secondary, tertiary, light)
              colorIndex = _random.nextInt(math.min(4, colors.length));
            }
            break;
        }

        final baseColor = colors[colorIndex];

        // Adjust color based on color characteristic
        Color gradientColor;
        double opacity;

        switch (colorCharacteristic) {
          case AuraColorCharacteristic.VIVID:
            // Vivid theme: Maintain the vibrancy of original colors
            gradientColor = baseColor;
            opacity = 0.3 + _random.nextDouble() * 0.2;
            break;
          case AuraColorCharacteristic.GRAYSCALE:
            // Grayscale theme: Convert to grayscale and slightly brighten
            final brightness = _calculateColorBrightness(baseColor);
            gradientColor = Color.fromRGBO(
              (brightness * 255).round(),
              (brightness * 255).round(),
              (brightness * 255).round(),
              1.0,
            );
            gradientColor = Color.lerp(gradientColor, colorPalette.light,
                0.1 + _random.nextDouble() * 0.2)!;
            opacity = 0.2 + _random.nextDouble() * 0.15; // Maintain opacity
            break;
          case AuraColorCharacteristic.DARK:
            // Dark theme: Adjust to darker tones
            gradientColor = Color.lerp(baseColor, colorPalette.dark,
                0.2 + _random.nextDouble() * 0.3)!;
            opacity = 0.2 + _random.nextDouble() * 0.15; // Maintain opacity
            break;
          case AuraColorCharacteristic.BRIGHT:
            // Bright theme: Adjust to brighter tones
            gradientColor = Color.lerp(baseColor, colorPalette.light,
                0.3 + _random.nextDouble() * 0.3)!;
            opacity = 0.2 + _random.nextDouble() * 0.15; // Maintain opacity
            break;
          case AuraColorCharacteristic.MEDIUM:
            // Medium tone theme: Slightly brighten
            gradientColor = Color.lerp(baseColor, colorPalette.light,
                0.1 + _random.nextDouble() * 0.2)!;
            opacity = 0.2 + _random.nextDouble() * 0.15; // Maintain opacity
            break;
        }

        // Calculate position (grid-based for more even distribution)
        // Distribute points more widely across the screen as there are fewer points
        final gridX = i % gridSize;
        final gridY = i ~/ gridSize;

        // Random position within grid cell (more even distribution than completely random)
        final position = Offset(
          (gridX * cellWidth) +
              (_random.nextDouble() * cellWidth * 0.8) +
              (cellWidth * 0.1),
          (gridY * cellHeight) +
              (_random.nextDouble() * cellHeight * 0.8) +
              (cellHeight * 0.1),
        );

        // Calculate size (70%-150% of screen width)
        // Set larger sizes for blur effects to spread more widely
        final size = containerSize.width * (0.7 + _random.nextDouble() * 0.8);

        points.add(_GradientPoint(
          color: gradientColor,
          position: position,
          size: size,
          opacity: opacity * animationValue,
        ));
      }
    }

    return points;
  }

  /// Generate basic gradient point (top center)
  _GradientPoint _generateBaseGradientPoint() {
    // Adjust gradient point position and size based on color characteristic
    double size;
    double opacity;
    Offset position;
    Color gradientColor;

    // Adjust size based on animation value (widening effect)
    final sizeMultiplier = 1.0 + (0.2 * animationValue);

    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        // Vivid theme: Large gradient, medium opacity, vibrant colors
        size = containerSize.width * 1.8 * sizeMultiplier; // Maintain size
        opacity = 0.5 * animationValue; // Slightly increase opacity
        position = Offset(
          containerSize.width * 0.5,
          -size * 0.3, // Position at top
        );

        // Maintain top highlight but use more vibrant colors
        // Use original colors to maximize vibrancy
        gradientColor = colorPalette.primary;
        break;
      case AuraColorCharacteristic.GRAYSCALE:
        // Grayscale theme: Small gradient, low opacity
        size = containerSize.width * 1.5 * sizeMultiplier; // Maintain size
        opacity = 0.35 * animationValue; // Maintain opacity
        position = Offset(
          containerSize.width * 0.5,
          -size * 0.4, // Position at top
        );
        // Mix dark and light colors for smooth gradient
        gradientColor = Color.lerp(colorPalette.light, colorPalette.dark, 0.4)!;
        break;
      case AuraColorCharacteristic.DARK:
        // Dark theme: Medium gradient, low opacity
        size = containerSize.width * 1.6 * sizeMultiplier; // Maintain size
        opacity = 0.35 * animationValue; // Maintain opacity
        position = Offset(
          containerSize.width * 0.6,
          -size * 0.4, // Position at top
        );
        // Mix primary and dark colors for smooth gradient
        gradientColor =
            Color.lerp(colorPalette.primary, colorPalette.dark, 0.3)!;
        break;
      case AuraColorCharacteristic.BRIGHT:
        // Bright theme: Large gradient, medium opacity
        size = containerSize.width * 1.7 * sizeMultiplier; // Maintain size
        opacity = 0.4 * animationValue; // Maintain opacity
        position = Offset(
          containerSize.width * 0.5,
          -size * 0.3, // Position at top
        );
        // Mix primary and light colors for natural gradient
        gradientColor =
            Color.lerp(colorPalette.primary, colorPalette.light, 0.5)!;
        break;
      case AuraColorCharacteristic.MEDIUM:
        // Medium tone theme: Medium gradient, medium opacity
        size = containerSize.width * 1.6 * sizeMultiplier; // Maintain size
        opacity = 0.35 * animationValue; // Maintain opacity
        position = Offset(
          containerSize.width * 0.5,
          -size * 0.4, // Position at top
        );
        // Mix light and primary colors for natural gradient
        gradientColor =
            Color.lerp(colorPalette.light, colorPalette.primary, 0.3)!;
        break;
    }

    return _GradientPoint(
      color: gradientColor,
      position: position,
      size: size,
      opacity: opacity,
    );
  }

  /// Calculate color brightness (0.0 ~ 1.0)
  double _calculateColorBrightness(Color color) {
    // Calculate brightness (Lightness) in HSL model
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;

    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));

    // Calculate L value of HSL
    return (max + min) / 2;
  }

  /// Initialize gradient
  void _initialize() {
    // Only regenerate gradient when container size, variety value, or animation value changes significantly
    if (_gradientPointsCache == null ||
        _lastContainerSize != containerSize ||
        _lastVariety != variety ||
        _lastAnimationValue != (animationValue * 10).round() / 10) {
      _gradientPointsCache = _generateGradientPoints();
      _lastContainerSize = containerSize;
      _lastVariety = variety;
      _lastAnimationValue = (animationValue * 10).round() / 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use parent class build method
    return super.build(context);
  }

  @override
  Widget buildBackgroundLayer() {
    // Adjust gradient position based on animation value
    final animationOffset = Alignment(0, 0.2 - (0.2 * animationValue));

    // Create gradient using only palette colors
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft + animationOffset,
          end: Alignment.bottomRight - animationOffset,
          colors: [
            colorPalette.primary.withOpacity(0.9 * animationValue),
            colorPalette.secondary.withOpacity(0.8 * animationValue),
            colorPalette.tertiary.withOpacity(0.7 * animationValue),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildBlurLayer() {
    // Adjust blur strength based on color characteristic
    double blurStrength;
    double opacityMultiplier;

    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        // Vivid theme: Minimize blur, maintain low opacity
        blurStrength = math.max(1.0, blurStrengthX / 4);
        opacityMultiplier = 0.2;
        break;
      case AuraColorCharacteristic.GRAYSCALE:
        // Grayscale theme: Medium blur, high opacity
        blurStrength = math.max(1.0, blurStrengthX / 2);
        opacityMultiplier = 0.6;
        break;
      case AuraColorCharacteristic.DARK:
        // Dark theme: Strong blur, high opacity
        blurStrength = math.max(1.0, blurStrengthX / 1.5);
        opacityMultiplier = 0.7;
        break;
      case AuraColorCharacteristic.BRIGHT:
        // Bright theme: Weak blur, medium opacity
        blurStrength = math.max(1.0, blurStrengthX / 2.5);
        opacityMultiplier = 0.4;
        break;
      case AuraColorCharacteristic.MEDIUM:
        // Medium tone theme: Medium blur, medium opacity
        blurStrength = math.max(1.0, blurStrengthX / 2);
        opacityMultiplier = 0.5;
        break;
    }

    return BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: blurStrength,
        sigmaY: blurStrength,
      ),
      child: Container(
        color: Colors.black.withOpacity(blurLayerOpacity * opacityMultiplier),
      ),
    );
  }

  @override
  Widget buildAuraLayer() {
    if (containerSize.width <= 0 ||
        containerSize.height <= 0 ||
        animationValue <= 0.01) {
      return Container();
    }

    return ClipRect(
      child: Stack(
        children: [
          // Highlight layer
          CustomPaint(
            size: containerSize,
            painter: _HighlightPainter(
              highlightPoints: _highlightPoints,
              variety: variety,
              animationValue: animationValue,
              colorCharacteristic: colorCharacteristic,
              colorPalette: colorPalette,
            ),
          ),

          // Blur layer
          BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 15.0 + (25.0 * variety),
              sigmaY: 15.0 + (25.0 * variety),
            ),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}

/// 그라디언트를 그리는 커스텀 페인터
class _GradientPainter extends CustomPainter {
  final List<_GradientPoint> gradientPoints;
  final double variety;
  final double animationValue;
  final AuraColorCharacteristic colorCharacteristic;

  _GradientPainter({
    required this.gradientPoints,
    required this.variety,
    required this.animationValue,
    required this.colorCharacteristic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    BlendMode blendMode;

    // Adjust blending mode based on color characteristic
    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        blendMode = BlendMode.screen; // Always use screen mode (sharper)
        break;
      case AuraColorCharacteristic.GRAYSCALE:
        blendMode = variety > 0.3 ? BlendMode.multiply : BlendMode.srcOver;
        break;
      case AuraColorCharacteristic.DARK:
        blendMode = variety > 0.3 ? BlendMode.darken : BlendMode.srcOver;
        break;
      case AuraColorCharacteristic.BRIGHT:
        blendMode = variety > 0.3 ? BlendMode.softLight : BlendMode.srcOver;
        break;
      case AuraColorCharacteristic.MEDIUM:
        blendMode = variety > 0.3 ? BlendMode.softLight : BlendMode.srcOver;
        break;
    }

    for (final point in gradientPoints) {
      double blurMultiplier = 1.0;
      if (colorCharacteristic == AuraColorCharacteristic.VIVID) {
        blurMultiplier = 0.7;
      }

      final radius = point.size / 2 * (1.0 + variety * 1.0);

      // Calculate gradient position
      final center = Offset(point.position.dx, point.position.dy);

      // Calculate gradient colors and stops
      List<Color> colors;

      // Use more vibrant colors for vivid theme
      if (colorCharacteristic == AuraColorCharacteristic.VIVID) {
        colors = [
          point.color.withOpacity(point.opacity * 0.8),
          point.color.withOpacity(point.opacity * 0.6),
          point.color.withOpacity(point.opacity * 0.3),
          point.color.withOpacity(point.opacity * 0.1),
          Colors.transparent,
        ];
      } else {
        colors = [
          point.color.withOpacity(point.opacity * 0.6),
          point.color.withOpacity(point.opacity * 0.4),
          point.color.withOpacity(point.opacity * 0.2),
          point.color.withOpacity(point.opacity * 0.05),
          Colors.transparent,
        ];
      }

      // Adjust stops based on variety
      final stops = [
        0.0,
        0.2 + (variety * 0.1),
        0.4 + (variety * 0.1),
        0.7 + (variety * 0.1),
        1.0,
      ];

      // First gradient (large blur)
      final bigBlurPaint = Paint()
        ..shader = RadialGradient(
          colors: colors,
          stops: stops,
          center: Alignment.center,
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.8))
        ..blendMode = blendMode
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, (50.0 + (40.0 * variety)) * blurMultiplier);

      // Draw elliptical gradient
      final bigRect = Rect.fromCenter(
        center: center,
        width: radius * 3.5,
        height: radius * 3.0,
      );
      canvas.drawOval(bigRect, bigBlurPaint);

      // Second gradient (medium blur)
      final mediumBlendMode;
      switch (colorCharacteristic) {
        case AuraColorCharacteristic.VIVID:
          mediumBlendMode = BlendMode.screen;
          break;
        case AuraColorCharacteristic.GRAYSCALE:
          mediumBlendMode = BlendMode.multiply;
          break;
        case AuraColorCharacteristic.DARK:
          mediumBlendMode = BlendMode.darken;
          break;
        case AuraColorCharacteristic.BRIGHT:
          mediumBlendMode = BlendMode.softLight;
          break;
        case AuraColorCharacteristic.MEDIUM:
          mediumBlendMode = BlendMode.softLight;
          break;
      }

      final mediumBlurPaint = Paint()
        ..shader = RadialGradient(
          colors: colors.map((c) => c.withOpacity(c.opacity * 0.7)).toList(),
          stops: stops,
          center: Alignment.center,
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5))
        ..blendMode = mediumBlendMode
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, (35.0 + (30.0 * variety)) * blurMultiplier);

      final mediumRect = Rect.fromCenter(
        center: center,
        width: radius * 3.0,
        height: radius * 2.5,
      );
      canvas.drawOval(mediumRect, mediumBlurPaint);

      // Third gradient (small blur, emphasize center)
      final smallBlendMode;
      switch (colorCharacteristic) {
        case AuraColorCharacteristic.VIVID:
          smallBlendMode = BlendMode.screen;
          break;
        case AuraColorCharacteristic.GRAYSCALE:
          smallBlendMode = BlendMode.multiply;
          break;
        case AuraColorCharacteristic.DARK:
          smallBlendMode = BlendMode.darken;
          break;
        case AuraColorCharacteristic.BRIGHT:
          smallBlendMode = BlendMode.softLight;
          break;
        case AuraColorCharacteristic.MEDIUM:
          smallBlendMode = BlendMode.softLight;
          break;
      }

      final smallBlurPaint = Paint()
        ..shader = RadialGradient(
          colors: colors.map((c) => c.withOpacity(c.opacity * 0.8)).toList(),
          stops: stops,
          center: Alignment.center,
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2))
        ..blendMode = smallBlendMode
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, (20.0 + (15.0 * variety)) * blurMultiplier);

      final smallRect = Rect.fromCenter(
        center: center,
        width: radius * 2.4,
        height: radius * 2.0,
      );
      canvas.drawOval(smallRect, smallBlurPaint);
    }

    // Additional effect when variety is high (subtle texture like Apple Music)
    if (variety > 0.3) {
      // Adjust overlay effect based on color characteristic
      if (colorCharacteristic == AuraColorCharacteristic.VIVID) {
        // Vivid theme: Remove overlay effect (prevent blurry effect)
        // Minimize noise effect
        final random = math.Random(42); // Fixed seed for consistent pattern
        final pointCount =
            (size.width * size.height / 3000).round(); // Reduce noise points

        for (int i = 0; i < pointCount; i++) {
          // Noise color is also more vibrant
          final colorIndex = random.nextInt(gradientPoints.length);
          final noiseColor = gradientPoints[colorIndex]
              .color
              .withOpacity(0.003 * variety * animationValue); // Reduce opacity

          final noisePaint = Paint()
            ..color = noiseColor
            ..blendMode = BlendMode.screen // More vibrant blend mode
            ..maskFilter =
                MaskFilter.blur(BlurStyle.normal, 1.0); // Reduce blur

          final x = random.nextDouble() * size.width;
          final y = random.nextDouble() * size.height;
          final radius = 0.2 + random.nextDouble() * 0.3; // Reduce size

          canvas.drawCircle(Offset(x, y), radius, noisePaint);
        }
      } else {
        // Other color characteristics: Keep existing code
        final overlayPaint = Paint()
          ..color = Colors.white
              .withOpacity(0.01 * variety * animationValue) // Reduce opacity
          ..blendMode = BlendMode.overlay;

        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

        // Add subtle noise effect (small points)
        final random = math.Random(42); // Fixed seed for consistent pattern
        final pointCount =
            (size.width * size.height / 1200).round(); // Reduce noise points

        final noisePaint = Paint()
          ..color = Colors.white
              .withOpacity(0.005 * variety * animationValue) // Reduce opacity
          ..blendMode = BlendMode.overlay
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, 2.0); // Add slight blur to noise

        for (int i = 0; i < pointCount; i++) {
          final x = random.nextDouble() * size.width;
          final y = random.nextDouble() * size.height;
          final radius = 0.2 + random.nextDouble() * 0.5;

          canvas.drawCircle(Offset(x, y), radius, noisePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GradientPainter oldDelegate) {
    return oldDelegate.variety != variety ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.gradientPoints != gradientPoints ||
        oldDelegate.colorCharacteristic != colorCharacteristic;
  }
}

class _HighlightPainter extends CustomPainter {
  final List<_HighlightPoint> highlightPoints;
  final double variety;
  final double animationValue;
  final AuraColorCharacteristic colorCharacteristic;
  final AuraColorPalette colorPalette;

  _HighlightPainter({
    required this.highlightPoints,
    required this.variety,
    required this.animationValue,
    required this.colorCharacteristic,
    required this.colorPalette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final point in highlightPoints) {
      if (variety < point.varietyThreshold) continue;

      double opacityMultiplier = 1.0;
      if (point.varietyThreshold > 0.0) {
        final nextThreshold = point.varietyThreshold + 0.4;
        if (variety < nextThreshold) {
          opacityMultiplier = (variety - point.varietyThreshold) / 0.4;
        }
      }

      Color gradientColor;
      double baseOpacity = point.baseOpacity;
      double blurStrength;
      BlendMode blendMode = BlendMode.srcOver; // Default blend mode

      // Modify color selection logic based on position
      if (point.position.dy < 0) {
        // Top highlight
        gradientColor = colorPalette.primary;
        blurStrength = 20.0;
      } else if (point.position.dy > size.height * 0.7) {
        // Bottom highlight
        gradientColor = colorPalette.primary;
        blurStrength = 25.0;
      } else {
        // Middle area highlight - Use only palette colors
        final horizontalPosition = point.position.dx / size.width;
        final verticalPosition = point.position.dy / size.height;

        // Color mix based on position
        if (horizontalPosition < 0.5) {
          gradientColor = Color.lerp(
            colorPalette.secondary,
            colorPalette.tertiary,
            verticalPosition,
          )!;
        } else {
          gradientColor = Color.lerp(
            colorPalette.tertiary,
            colorPalette.secondary,
            verticalPosition,
          )!;
        }
        blurStrength = 30.0;
      }

      final opacity = baseOpacity * opacityMultiplier * animationValue;

      // For irregular shape, multiple gradient layers
      for (int i = 0; i < 3; i++) {
        // Adjust color for each layer - Use only palette colors
        Color layerColor;
        if (i == 0) {
          layerColor = gradientColor;
        } else if (i == 1) {
          layerColor = Color.lerp(
            gradientColor,
            colorPalette.secondary,
            0.4,
          )!;
        } else {
          layerColor = Color.lerp(
            gradientColor,
            colorPalette.tertiary,
            0.4,
          )!;
        }

        final offset = Offset(
          math.cos(i * math.pi * 2 / 3) * (point.size * 0.1),
          math.sin(i * math.pi * 2 / 3) * (point.size * 0.1),
        );

        // Gradient colors - Adjust only opacity
        final colors = [
          layerColor.withOpacity(opacity),
          layerColor.withOpacity(opacity * 0.6),
          layerColor.withOpacity(opacity * 0.3),
          layerColor.withOpacity(opacity * 0.1),
          Colors.transparent,
        ];

        final stops = [0.0, 0.3, 0.6, 0.8, 1.0];

        final paint = Paint()
          ..shader = RadialGradient(
            colors: colors,
            stops: stops,
            center: Alignment.center,
            radius: 1.0,
          ).createShader(
            Rect.fromCircle(
              center: point.position + offset,
              radius: point.size / 2 * (1.0 + (i * 0.15)),
            ),
          )
          ..blendMode = blendMode
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            blurStrength * (1.0 + (i * 0.15)),
          );

        // Create irregular shape
        final rotationAngle = i * math.pi / 4;
        final rect = Rect.fromCenter(
          center: point.position + offset,
          width: point.size * (1.0 + (i * 0.1)),
          height: point.size * (0.85 + (i * 0.1)),
        );

        canvas.save();
        canvas.translate(point.position.dx, point.position.dy);
        canvas.rotate(rotationAngle);
        canvas.translate(-point.position.dx, -point.position.dy);
        canvas.drawOval(rect, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HighlightPainter oldDelegate) {
    return oldDelegate.variety != variety ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.colorCharacteristic != colorCharacteristic;
  }
}

/// Return the color that contrasts most with the given base color
Color _getContrastColor({
  required Color baseColor,
  required Color option1,
  required Color option2,
}) {
  // Calculate hue distance in hue space (0-360 degrees)
  final baseHSV = _colorToHSV(baseColor);
  final option1HSV = _colorToHSV(option1);
  final option2HSV = _colorToHSV(option2);

  // Calculate hue distance in hue space (0-360 degrees)
  final diff1 = _calculateHueDistance(baseHSV[0], option1HSV[0]);
  final diff2 = _calculateHueDistance(baseHSV[0], option2HSV[0]);

  // Consider saturation and value differences
  final satDiff1 = (baseHSV[1] - option1HSV[1]).abs();
  final satDiff2 = (baseHSV[1] - option2HSV[1]).abs();
  final valDiff1 = (baseHSV[2] - option1HSV[2]).abs();
  final valDiff2 = (baseHSV[2] - option2HSV[2]).abs();

  // Calculate comprehensive contrast score
  final score1 = diff1 * 0.6 + satDiff1 * 0.2 + valDiff1 * 0.2;
  final score2 = diff2 * 0.6 + satDiff2 * 0.2 + valDiff2 * 0.2;

  // Return the color with the higher contrast score
  return score1 > score2 ? option1 : option2;
}

/// Convert RGB color to HSV
List<double> _colorToHSV(Color color) {
  final r = color.red / 255.0;
  final g = color.green / 255.0;
  final b = color.blue / 255.0;

  final max = math.max(r, math.max(g, b));
  final min = math.min(r, math.min(g, b));
  final delta = max - min;

  double hue = 0.0;
  if (delta != 0) {
    if (max == r) {
      hue = 60.0 * (((g - b) / delta) % 6);
    } else if (max == g) {
      hue = 60.0 * (((b - r) / delta) + 2);
    } else {
      hue = 60.0 * (((r - g) / delta) + 4);
    }
  }
  if (hue < 0) hue += 360;

  final saturation = max == 0 ? 0.0 : delta / max;
  final value = max;

  return [hue, saturation, value];
}

/// Calculate hue distance between two colors
double _calculateHueDistance(double hue1, double hue2) {
  final diff = (hue1 - hue2).abs();
  return math.min(diff, 360 - diff) / 180.0; // Normalize to 0-1 range
}
