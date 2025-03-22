part of '../adaptive_aura.dart';

/// 이미지에서 색상을 추출하는 유틸리티 클래스
class ColorExtractor {
  /// 이미지에서 색상 팔레트 추출
  static Future<AuraColorPalette> extractColorsFromImage({
    required ImageProvider imageProvider,
    bool enableLogging = false,
  }) async {
    try {
      if (enableLogging) {
        debugPrint('🎨 이미지에서 색상 추출 시작...');
      }

      // 이미지 로드
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

      // 이미지 크기 확인
      final width = image.width;
      final height = image.height;

      if (enableLogging) {
        debugPrint('📏 이미지 크기: $width x $height');
      }

      // 이미지 데이터 추출
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        throw Exception('이미지 데이터를 추출할 수 없습니다.');
      }

      final pixels = byteData.buffer.asUint8List();
      final colors = <Color>[];

      // 샘플링할 픽셀 수 (성능 최적화를 위해 모든 픽셀을 처리하지 않음)
      final sampleSize = (width * height) ~/ 100;
      final step = (width * height) ~/ sampleSize;

      for (int i = 0; i < pixels.length; i += step * 4) {
        if (i + 3 < pixels.length) {
          final r = pixels[i];
          final g = pixels[i + 1];
          final b = pixels[i + 2];
          final a = pixels[i + 3];

          // 투명한 픽셀은 무시
          if (a > 0) {
            colors.add(Color.fromARGB(a, r, g, b));
          }
        }
      }

      if (enableLogging) {
        debugPrint('🔍 샘플링된 색상 수: ${colors.length}');
      }

      // 색상이 없으면 기본 팔레트 반환
      if (colors.isEmpty) {
        if (enableLogging) {
          debugPrint('⚠️ 추출된 색상이 없습니다. 기본 팔레트를 사용합니다.');
        }
        return AuraColorPalette.defaultPalette();
      }

      // 색상 정렬 (밝기 기준)
      colors.sort((a, b) {
        final brightnessA = (0.299 * a.red + 0.587 * a.green + 0.114 * a.blue);
        final brightnessB = (0.299 * b.red + 0.587 * b.green + 0.114 * b.blue);
        return brightnessB.compareTo(brightnessA);
      });

      // 주요 색상 선택
      final primary = colors[colors.length ~/ 3];
      final secondary = colors[colors.length ~/ 2];
      final tertiary = colors[colors.length ~/ 4];
      final light = colors.first;
      final dark = colors.last;

      if (enableLogging) {
        debugPrint('✅ 색상 추출 완료');
      }

      return AuraColorPalette(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        light: light,
        dark: dark,
      );
    } catch (e) {
      debugPrint('❌ 색상 추출 중 오류 발생: $e');
      return AuraColorPalette.defaultPalette();
    }
  }
}
