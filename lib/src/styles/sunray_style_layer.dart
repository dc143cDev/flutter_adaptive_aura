import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'aura_style_layer.dart';
import '../models/aura_color_palette.dart';

/// Implementation of the sunray style layer
class SunrayStyleLayer extends AuraStyleLayer {
  /// Animation state value (0.0 ~ 1.0)
  final double animationValue;

  /// Container size
  @override
  final Size containerSize;

  /// Constructor
  SunrayStyleLayer({
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
  });

  /// Calculate effective ray count based on variety value
  int get _effectiveRayCount {
    // Adjusts ray count inversely with variety
    // Lower variety means more rays (thinner and denser rays)
    final maxRayCount = 100; // Maximum ray count at variety 0.0
    final minRayCount =
        36; // Minimum ray count at variety 1.0 (wider and fewer rays)

    final count = maxRayCount - ((maxRayCount - minRayCount) * variety).round();
    return (count ~/ 4) * 4; // Adjust to multiples of 4
  }

  /// Calculate effective ray thickness based on variety value
  double get _effectiveRayThickness {
    // Increase thickness with variety - start with extremely thin rays
    final minThickness = 0.05; // Thickness at variety 0.0 (extremely thin)
    final maxThickness = 45.0; // Thickness at variety 1.0

    // Rapidly thicken in the first 0.1 range, then more gradually
    if (variety < 0.1) {
      // Increase more rapidly in 0.0~0.1 range (from 0.05 to about 5.0)
      return minThickness + ((5.0 - minThickness) * (variety / 0.1));
    } else {
      // Increase linearly after 0.1
      return 5.0 + ((maxThickness - 5.0) * ((variety - 0.1) / 0.9));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use parent class build method
    return super.build(context);
  }

  @override
  Widget buildBackgroundLayer() {
    // Reduce background opacity for a brighter look
    double opacity = math.min(1.0, animationValue * (0.2 + variety * 0.4));

    return Container(
      color: colorPalette.dark.withOpacity(opacity),
    );
  }

  @override
  Widget buildBlurLayer() {
    // Don't apply blur effect if blur strength is 0.0
    if (blurStrengthX <= 0.0 && blurStrengthY <= 0.0) {
      return Container(
        color: Colors.black.withOpacity(blurLayerOpacity),
      );
    }

    // Apply normal blur effect
    return BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: blurStrengthX,
        sigmaY: blurStrengthY,
      ),
      child: Container(
        color: Colors.black.withOpacity(blurLayerOpacity),
      ),
    );
  }

  @override
  Widget buildAuraLayer() {
    if (animationValue <= 0.01 ||
        containerSize.width <= 0 ||
        containerSize.height <= 0) {
      return Container();
    }

    // Draw rays - apply blur to the entire layer
    return BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: math.min(10.0, blurStrengthX * 0.2), // Limit to safe range
        sigmaY: math.min(10.0, blurStrengthY * 0.2), // Limit to safe range
      ),
      child: CustomPaint(
        size: containerSize,
        painter: _SunrayPainter(
          colorPalette: colorPalette,
          animationValue: animationValue,
          rayCount: _effectiveRayCount,
          rayThickness: _effectiveRayThickness,
          colorIntensity: colorIntensity,
          colorCharacteristic: colorCharacteristic,
          variety: variety,
          blurStrengthX: 0, // Don't apply blur to individual rays
          blurStrengthY: 0, // Don't apply blur to individual rays
        ),
      ),
    );
  }
}

/// Custom painter for drawing sunrays
class _SunrayPainter extends CustomPainter {
  final AuraColorPalette colorPalette;
  final double animationValue;
  final int rayCount;
  final double rayThickness;
  final double colorIntensity;
  final AuraColorCharacteristic colorCharacteristic;
  final double variety;
  final double blurStrengthX;
  final double blurStrengthY;

  _SunrayPainter({
    required this.colorPalette,
    required this.animationValue,
    required this.rayCount,
    required this.rayThickness,
    required this.colorIntensity,
    required this.colorCharacteristic,
    required this.variety,
    required this.blurStrengthX,
    required this.blurStrengthY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Canvas center
    final center = Offset(size.width / 2, size.height / 2);

    // Diagonal length (distance to screen corner)
    final diagonalLength =
        math.sqrt(size.width * size.width + size.height * size.height);

    // Prepare color list
    final colors = _prepareColors();

    // Angle interval for each ray
    final double angleStep = 2 * math.pi / rayCount;

    // Animation angle offset (rotation effect)
    final angleOffset = animationValue * 0.05 * math.pi;

    // Draw all rays
    for (int i = 0; i < rayCount; i++) {
      // Current ray angle
      final angle = i * angleStep + angleOffset;

      // Calculate ray endpoint
      final rayEnd = Offset(
        center.dx + diagonalLength * math.cos(angle),
        center.dy + diagonalLength * math.sin(angle),
      );

      // Select current ray color (cycle through color list)
      final baseColor = colors[i % colors.length];

      // Draw ray
      _drawRay(canvas, center, rayEnd, baseColor, i);
    }
  }

  /// Prepare color list to use
  List<Color> _prepareColors() {
    final List<Color> colors = [];

    // Adjust colors based on color characteristic - use brighter colors
    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        // Vivid theme: More vibrant and bright primary colors
        colors.add(colorPalette.primary);
        colors.add(colorPalette.secondary);
        colors.add(colorPalette.tertiary);
        // Add brighter colors
        colors.add(Color.lerp(colorPalette.primary, Colors.white, 0.2)!);
        colors.add(Color.lerp(colorPalette.secondary, Colors.white, 0.2)!);
        colors.add(Color.lerp(colorPalette.tertiary, Colors.white, 0.2)!);
        break;

      case AuraColorCharacteristic.GRAYSCALE:
        // Grayscale theme: Very bright black and white gradients
        colors.add(Colors.white);
        colors.add(Color.lerp(Colors.white, Colors.grey, 0.2)!);
        colors.add(Color.lerp(Colors.white, Colors.grey, 0.4)!);
        colors.add(Colors.grey[300]!);
        colors.add(Colors.grey[500]!);
        colors.add(Colors.grey[700]!);
        break;

      case AuraColorCharacteristic.DARK:
        // Dark theme: Brighter than before
        colors.add(colorPalette.primary);
        colors.add(colorPalette.secondary);
        colors.add(colorPalette.tertiary);
        colors.add(Color.lerp(colorPalette.primary, Colors.black, 0.2)!);
        colors.add(Color.lerp(colorPalette.secondary, Colors.black, 0.2)!);
        colors.add(Color.lerp(colorPalette.tertiary, Colors.black, 0.2)!);
        break;

      case AuraColorCharacteristic.BRIGHT:
        // Bright theme: Very bright
        colors.add(colorPalette.primary);
        colors.add(colorPalette.secondary);
        colors.add(colorPalette.tertiary);
        colors.add(Color.lerp(colorPalette.primary, Colors.white, 0.5)!);
        colors.add(Color.lerp(colorPalette.secondary, Colors.white, 0.5)!);
        colors.add(Color.lerp(colorPalette.tertiary, Colors.white, 0.5)!);
        break;

      case AuraColorCharacteristic.MEDIUM:
        // Medium tone theme: Brighter adjustment
        colors.add(colorPalette.primary);
        colors.add(colorPalette.secondary);
        colors.add(colorPalette.tertiary);
        colors.add(Color.lerp(colorPalette.primary, Colors.white, 0.3)!);
        colors.add(Color.lerp(colorPalette.secondary, Colors.white, 0.3)!);
        colors.add(Color.lerp(colorPalette.tertiary, Colors.white, 0.3)!);
        break;
    }

    return colors;
  }

  /// Draw a ray
  void _drawRay(Canvas canvas, Offset center, Offset rayEnd, Color baseColor,
      int rayIndex) {
    // Calculate angle for cone shape
    final double angle =
        math.atan2(rayEnd.dy - center.dy, rayEnd.dx - center.dx);
    final double distance = (center - rayEnd).distance;

    // Adjust ray width based on variety (wider fan shape)
    final double fanAngle = math.pi / rayCount * (1.0 + variety * 3.0);

    // Create fan path
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: distance),
        angle - fanAngle / 2,
        fanAngle,
        false,
      )
      ..lineTo(center.dx, center.dy)
      ..close();

    // Adjust opacity based on color characteristic
    final opacityMultiplier =
        colorCharacteristic == AuraColorCharacteristic.VIVID
            ? 2.0
            : colorCharacteristic == AuraColorCharacteristic.BRIGHT
                ? 1.8
                : colorCharacteristic == AuraColorCharacteristic.MEDIUM
                    ? 1.5
                    : 1.2;

    // Base opacity values (overall brighter)
    const baseOpacity = 0.5;
    const tailOpacity = 0.2;

    // Create gradient (bright and vibrant colors)
    final Paint fanPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        distance,
        [
          baseColor.withOpacity(baseOpacity *
              colorIntensity *
              animationValue *
              opacityMultiplier),
          baseColor.withOpacity(tailOpacity *
              colorIntensity *
              animationValue *
              opacityMultiplier),
          Colors.transparent,
        ],
        [0.0, 0.7, 1.0],
      )
      ..style = PaintingStyle.fill;

    // Don't apply blur to individual rays (blur is applied to entire layer)

    // Draw fan shape
    canvas.drawPath(path, fanPaint);

    // Add additional center ray when variety is high (bright center part)
    if (variety > 0.1) {
      // Show center ray even at lower variety
      // Start with thinner line at low variety
      final centerLineWidth = rayThickness * (0.1 + (variety * 0.9));
      final centerLinePaint = Paint()
        ..shader = ui.Gradient.linear(
          center,
          rayEnd,
          [
            baseColor.withOpacity(baseOpacity *
                2.5 *
                colorIntensity *
                animationValue *
                opacityMultiplier),
            baseColor.withOpacity(tailOpacity *
                1.5 *
                colorIntensity *
                animationValue *
                opacityMultiplier),
          ],
          [0.0, 1.0],
        )
        ..strokeWidth = centerLineWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Don't apply blur to individual rays (blur is applied to entire layer)

      canvas.drawLine(center, rayEnd, centerLinePaint);
    }
  }

  @override
  bool shouldRepaint(_SunrayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.rayCount != rayCount ||
        oldDelegate.rayThickness != rayThickness ||
        oldDelegate.colorIntensity != colorIntensity ||
        oldDelegate.colorCharacteristic != colorCharacteristic ||
        oldDelegate.colorPalette != colorPalette ||
        oldDelegate.variety != variety ||
        oldDelegate.blurStrengthX != blurStrengthX ||
        oldDelegate.blurStrengthY != blurStrengthY;
  }
}
