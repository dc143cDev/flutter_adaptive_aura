import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'aura_style_layer.dart';

/// Global class for storing random values
/// This allows random values to persist even when the widget rebuilds
class _BlobStyleConfig {
  static final _BlobStyleConfig _instance = _BlobStyleConfig._internal();

  factory _BlobStyleConfig() {
    return _instance;
  }

  _BlobStyleConfig._internal() {
    _initialize();
  }

  /// Random generator
  final _random = math.Random();

  /// Blob position offsets (randomly generated)
  late final List<Offset> blobOffsets;

  /// Blob sizes (randomly generated)
  late final List<double> blobSizes;

  /// Blob rotation angles (randomly generated)
  late final List<double> blobRotations;

  /// Blob movement vectors and distances (randomly generated)
  late final List<Offset> blobMovementVectors;

  /// Small point movement vectors and distances (randomly generated)
  late final List<Offset> smallBlobMovementVectors;

  /// Small point positions (randomly generated)
  late final List<Offset> smallBlobOffsets;

  /// Small point sizes (randomly generated)
  late final List<double> smallBlobSizes;

  /// Small point rotations (randomly generated)
  late final List<double> smallBlobRotations;

  /// Initialization status
  bool _isInitialized = false;

  /// Maximum blob count
  static const int maxBlobCount = 100;

  /// Maximum small point count
  static const int maxSmallBlobCount = 200;

  void _initialize() {
    if (_isInitialized) return;

    // Initialize lists with maximum count
    // Create blob movement vectors (movement distance: 6~16 pixels)
    blobMovementVectors = List.generate(maxBlobCount,
        (_) => _generateRandomMovementVector(minDistance: 6, maxDistance: 16));

    // Create small point movement vectors (movement distance: 4~10 pixels)
    smallBlobMovementVectors = List.generate(maxSmallBlobCount,
        (_) => _generateRandomMovementVector(minDistance: 4, maxDistance: 10));

    // Generate random blob positions, sizes, and rotations
    blobOffsets = List.generate(maxBlobCount, (_) => _randomOffset());
    blobSizes = List.generate(maxBlobCount, (_) => _randomSize());
    blobRotations = List.generate(maxBlobCount, (_) => _randomRotation());

    // Generate small point positions, sizes, and rotations
    smallBlobOffsets = List.generate(maxSmallBlobCount, (_) => _randomOffset());
    smallBlobSizes =
        List.generate(maxSmallBlobCount, (_) => _randomSmallSize());
    smallBlobRotations =
        List.generate(maxSmallBlobCount, (_) => _randomRotation());

    _isInitialized = true;
  }

  /// Generate random movement vector (specified distance range and random direction)
  Offset _generateRandomMovementVector(
      {double minDistance = 6, double maxDistance = 16}) {
    // Random distance (default: 6~16 pixels)
    final distance =
        minDistance + _random.nextDouble() * (maxDistance - minDistance);

    // Random angle (0~2π)
    final angle = _random.nextDouble() * 2 * math.pi;

    // Convert polar coordinates to Cartesian coordinates
    return Offset(
      distance * math.cos(angle),
      distance * math.sin(angle),
    );
  }

  /// Generate random offset (-0.8 ~ 0.8 range)
  Offset _randomOffset() {
    return Offset(
      _random.nextDouble() * 1.6 - 0.8,
      _random.nextDouble() * 1.6 - 0.8,
    );
  }

  /// Generate random size (100 ~ 350 range)
  double _randomSize() {
    return 100.0 + _random.nextDouble() * 250.0;
  }

  /// Generate random small size (20 ~ 60 range)
  double _randomSmallSize() {
    return 20.0 + _random.nextDouble() * 40.0;
  }

  /// Generate random rotation (0 ~ 2π range)
  double _randomRotation() {
    return _random.nextDouble() * 2 * math.pi;
  }
}

/// Class for storing blob information
class _BlobInfo {
  final Color color;
  final double size;
  final Offset offset;
  final double rotation;
  final Offset movementVector;
  final int index;

  _BlobInfo({
    required this.color,
    required this.size,
    required this.offset,
    required this.rotation,
    required this.movementVector,
    required this.index,
  });
}

/// Implementation of blob style layer
class BlobStyleLayer extends AuraStyleLayer {
  /// Animation state value (0.0 ~ 1.0)
  final double animationValue;

  /// Container size
  final Size containerSize;

  /// Shared configuration instance
  final _config = _BlobStyleConfig();

  /// Whether to use blur effect
  bool get _useBlurEffect => blurStrengthX > 0.0 || blurStrengthY > 0.0;

  /// Constructor
  BlobStyleLayer({
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

  /// Calculate effective blob count based on variety value
  int get _effectiveBlobCount {
    final minCount = 5;
    final maxCount = _BlobStyleConfig.maxBlobCount;
    return minCount + ((maxCount - minCount) * variety).round();
  }

  /// Calculate effective small blob count based on variety value
  int get _effectiveSmallBlobCount {
    final minCount = 10;
    final maxCount = _BlobStyleConfig.maxSmallBlobCount;
    return minCount + ((maxCount - minCount) * variety).round();
  }

  /// Calculate pulse scale based on animation value
  double _calculatePulseScale(int index) {
    // Base scale (0.99 ~ 1.01)
    final baseScale = 0.99 + (0.02 * animationValue);

    // Apply slightly different scale for each blob
    final randomOffset = (index % 5) * 0.002 * animationValue;

    return baseScale + randomOffset;
  }

  /// Calculate movement offset based on animation value
  Offset _calculateMovementOffset(Offset vector, int index) {
    // Apply slightly different speed for each blob
    final progress = (animationValue + (index % 7) * 0.1) % 1.0;

    // Use sine curve for smooth back-and-forth movement
    final factor = math.sin(progress * math.pi) * animationValue;

    return Offset(vector.dx * factor, vector.dy * factor);
  }

  @override
  Widget build(BuildContext context) {
    // Use parent class build method
    return super.build(context);
  }

  @override
  Widget buildBackgroundLayer() {
    // Get background settings based on color characteristic
    final settings = getBackgroundSettingsForCharacteristic();

    // Select background color (mix of light color and primary color)
    final backgroundColor1 = Color.lerp(
        colorPalette.light,
        colorPalette.primary.withOpacity(settings.primaryOpacity),
        math.max(0.0, 1.0 - settings.lightColorWeight))!;

    final backgroundColor2 = Color.lerp(
        colorPalette.light,
        colorPalette.secondary.withOpacity(settings.secondaryOpacity),
        math.max(0.0, 0.9 - settings.lightColorWeight))!;

    // Create background gradient
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor1.withOpacity(math.min(settings.backgroundOpacity1,
                settings.backgroundOpacity1 * animationValue)),
            backgroundColor2.withOpacity(math.min(settings.backgroundOpacity2,
                settings.backgroundOpacity2 * animationValue)),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildBlurLayer() {
    // Don't apply blur effect if blur strength is 0.0
    if (!_useBlurEffect) {
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
    // Return empty container if animation value is 0
    if (animationValue <= 0.01) {
      return Container();
    }

    // Check if container size is valid
    final hasValidSize = containerSize.width > 0 && containerSize.height > 0;
    if (!hasValidSize) {
      return Container();
    }

    // Generate all blob information and sort by size (small to large)
    List<_BlobInfo> allBlobs = [];

    // Add main blob
    // allBlobs.add(_BlobInfo(
    //   color: colorPalette.primary,
    //   size: math.min(containerSize.width, containerSize.height) *
    //       0.6 *
    //       animationValue,
    //   offset: const Offset(0, 0),
    //   rotation: 0,
    //   movementVector: Offset.zero,
    //   index: 0,
    // ));

    // Calculate actual blob count based on variety value
    final blobCount = _effectiveBlobCount;
    final smallBlobCount = _effectiveSmallBlobCount;

    // Add regular blobs
    for (int index = 0; index < blobCount; index++) {
      Color color;
      switch (index % 4) {
        case 0:
          color = colorPalette.light;
          break;
        case 1:
          color = colorPalette.secondary;
          break;
        case 2:
          color = colorPalette.tertiary;
          break;
        default:
          color = colorPalette.primary.withOpacity(0.8);
      }

      final adjustedSize = _config.blobSizes[index] *
          math.min(containerSize.width, containerSize.height) /
          800 *
          animationValue;

      allBlobs.add(_BlobInfo(
        color: color,
        size: adjustedSize,
        offset: _config.blobOffsets[index],
        rotation: _config.blobRotations[index],
        movementVector: _config.blobMovementVectors[index],
        index: index + 1,
      ));
    }

    // Add small blobs
    for (int index = 0; index < smallBlobCount; index++) {
      final colors = [
        colorPalette.light,
        colorPalette.primary,
        colorPalette.secondary,
        colorPalette.tertiary,
      ];

      final adjustedSize = _config.smallBlobSizes[index] *
          math.min(containerSize.width, containerSize.height) /
          800 *
          animationValue;

      allBlobs.add(_BlobInfo(
        color: colors[index % colors.length],
        size: adjustedSize,
        offset: _config.smallBlobOffsets[index],
        rotation: _config.smallBlobRotations[index],
        movementVector: _config.smallBlobMovementVectors[index],
        index: index + blobCount + 1,
      ));
    }

    // Sort by size (small to large)
    allBlobs.sort((a, b) => a.size.compareTo(b.size));

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: allBlobs.map((blob) {
          // Calculate blur strength based on blob size
          final maxSize =
              math.min(containerSize.width, containerSize.height) * 0.6;
          final sizeRatio = blob.size / maxSize;

          // Calculate blur factor - only apply blur to very small blobs (default)
          double blurFactor;
          if (sizeRatio < 0.15) {
            // Very small blobs (size ratio < 15%) - strong blur
            blurFactor = 0.5;
          } else if (sizeRatio < 0.25) {
            // Small blobs (size ratio 15%~25%) - weak blur
            blurFactor = 0.2;
          } else {
            // Medium to large blobs (size ratio >= 25%) - no blur by default
            blurFactor = 0.0;
          }

          // Apply additional blur if user has set blur strength
          if (_useBlurEffect) {
            // Logic for applying additional blur based on strength (reduced maximum intensity)
            final blurStrengthRatio = math.max(blurStrengthX, blurStrengthY) /
                20.0; // Normalize to 0.0 ~ 0.5 range

            if (blurStrengthRatio > 0.1) {
              // For medium or higher blur strength
              if (sizeRatio < 0.4) {
                // Apply additional blur to small-medium blobs (reduced intensity)
                blurFactor = math.max(
                    blurFactor, (1.0 - sizeRatio) * 0.3 * blurStrengthRatio);
              } else if (blurStrengthRatio > 0.3) {
                // For high blur strength, apply very slight blur to large blobs too
                blurFactor = math.max(blurFactor, 0.05 * blurStrengthRatio);
              }
            }

            // When blur strength is near maximum, apply slight blur to all blobs
            if (blurStrengthRatio > 0.4) {
              // Apply blur strength inversely proportional to size (smaller = stronger blur, overall reduced intensity)
              final maxBlurFactor = 0.1 + (1.0 - sizeRatio) * 0.4;
              blurFactor =
                  math.max(blurFactor, maxBlurFactor * blurStrengthRatio);
            }
          }

          return _buildAuraBlob(
            scale: _calculatePulseScale(blob.index),
            movementOffset:
                _calculateMovementOffset(blob.movementVector, blob.index),
            color: blob.color,
            size: blob.size,
            offset: blob.offset,
            rotation: blob.rotation,
            index: blob.index,
            blurFactor: blurFactor, // Pass blur factor based on size
          );
        }).toList(),
      ),
    );
  }

  /// Create aura blob widget
  Widget _buildAuraBlob({
    required double scale,
    required Offset movementOffset,
    required Color color,
    required double size,
    required Offset offset,
    required double rotation,
    required int index,
    required double blurFactor, // Added blur factor parameter
  }) {
    // Return empty container if animation value is 0
    if (animationValue <= 0.01) {
      return Container();
    }

    // Calculate base position
    return Positioned.fill(
      child: Center(
        child: Builder(
          builder: (context) {
            // Use container size
            final screenSize = containerSize;

            // Check if screen size is valid
            final hasValidSize = screenSize.width > 0 && screenSize.height > 0;
            if (!hasValidSize) {
              return Container(); // Return empty container if size is invalid
            }

            // Calculate base position (constrained within container)
            final baseOffset = Offset(
              screenSize.width * offset.dx,
              screenSize.height * offset.dy,
            );

            // Calculate final position
            final finalOffset = baseOffset + movementOffset;

            // Check if scale is valid (not zero)
            final validScale = scale.isFinite && scale != 0;

            // Create blob widget - style determined by blur factor
            Widget blobWidget;

            if (blurFactor <= 0.01) {
              // Blob without blur (medium to large blobs)
              blobWidget = Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(colorIntensity * animationValue),
                ),
              );
            } else {
              // Blob with blur (small blobs or high blur strength)
              final isSmallBlob = size /
                      (math.min(containerSize.width, containerSize.height) *
                          0.6) <
                  0.25;

              // Small blobs use gradient, large blobs use solid color
              if (isSmallBlob) {
                blobWidget = Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color
                            .withOpacity(colorIntensity * 0.8 * animationValue),
                        color
                            .withOpacity(colorIntensity * 0.4 * animationValue),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              } else {
                blobWidget = Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(colorIntensity * animationValue),
                  ),
                );
              }

              // Apply blur effect (reduced intensity)
              final baseBlur =
                  math.min(1.5, blurFactor * 1.5); // Reduce base blur intensity
              final adjustedBlurX = _useBlurEffect
                  ? math.min(
                      3.0, math.max(baseBlur, blurStrengthX * blurFactor * 0.3))
                  : baseBlur;
              final adjustedBlurY = _useBlurEffect
                  ? math.min(
                      3.0, math.max(baseBlur, blurStrengthY * blurFactor * 0.3))
                  : baseBlur;

              blobWidget = ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: adjustedBlurX,
                  sigmaY: adjustedBlurY,
                ),
                child: blobWidget,
              );
            }

            return Transform.translate(
              offset: finalOffset,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale:
                      validScale ? scale : 1.0, // Handle invalid scale values
                  child: blobWidget,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
