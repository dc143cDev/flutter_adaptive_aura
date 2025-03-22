part of '../adaptive_aura.dart';

/// Utility class for extracting colors from images
class ColorExtractor {
  /// Extract color palette from an image
  static Future<AuraColorPalette> extractColorsFromImage({
    required ImageProvider imageProvider,
    bool enableLogging = false,
  }) async {
    try {
      if (enableLogging) {
        debugPrint('🎨 Starting color extraction from image...');
      }

      // Load image
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      final completer = Completer<ui.Image>();
      final listener = ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info.image);
        },
        onError: (exception, stackTrace) {
          completer.completeError(exception);
        },
      );

      imageStream.addListener(listener);
      final image = await completer.future;
      imageStream.removeListener(listener);

      // Check image dimensions
      final width = image.width;
      final height = image.height;

      if (enableLogging) {
        debugPrint('📏 Image size: $width x $height');
      }

      // Extract image data
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        throw Exception('Unable to extract image data');
      }

      final pixels = byteData.buffer.asUint8List();
      final colors = <Color>[];

      // Sampling pixel count (not processing all pixels for performance optimization)
      final sampleSize = (width * height) ~/ 100;
      final step = (width * height) ~/ sampleSize;

      for (int i = 0; i < pixels.length; i += step * 4) {
        if (i + 3 < pixels.length) {
          final r = pixels[i];
          final g = pixels[i + 1];
          final b = pixels[i + 2];
          final a = pixels[i + 3];

          // Ignore transparent pixels
          if (a > 0) {
            colors.add(Color.fromARGB(a, r, g, b));
          }
        }
      }

      if (enableLogging) {
        debugPrint('🔍 Number of sampled colors: ${colors.length}');
      }

      // Return default palette if no colors extracted
      if (colors.isEmpty) {
        if (enableLogging) {
          debugPrint('⚠️ No colors extracted. Using default palette.');
        }
        return AuraColorPalette.defaultPalette();
      }

      // Sort colors by brightness
      colors.sort((a, b) {
        final brightnessA = (0.299 * a.red + 0.587 * a.green + 0.114 * a.blue);
        final brightnessB = (0.299 * b.red + 0.587 * b.green + 0.114 * b.blue);
        return brightnessB.compareTo(brightnessA);
      });

      // Select main colors
      final primary = colors[colors.length ~/ 3];
      final secondary = colors[colors.length ~/ 2];
      final tertiary = colors[colors.length ~/ 4];
      final light = colors.first;
      final dark = colors.last;

      if (enableLogging) {
        debugPrint('✅ Color extraction complete');
      }

      return AuraColorPalette(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        light: light,
        dark: dark,
      );
    } catch (e) {
      debugPrint('❌ Error during color extraction: $e');
      return AuraColorPalette.defaultPalette();
    }
  }
}
