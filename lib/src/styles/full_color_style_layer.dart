import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'aura_style_layer.dart';
import '../models/aura_color_palette.dart';

/// 그라디언트 포인트 정보를 저장하는 클래스
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

/// 하이라이트 포인트 정보를 저장하는 클래스
class _HighlightPoint {
  final Offset position;
  final double size;
  final double baseOpacity;
  final double varietyThreshold; // 이 하이라이트가 활성화되는 버라이어티 임계값

  _HighlightPoint({
    required this.position,
    required this.size,
    required this.baseOpacity,
    required this.varietyThreshold,
  });
}

/// 애플 뮤직 스타일의 꽉 찬 색상 배경을 구현하는 레이어
class FullColorStyleLayer extends AuraStyleLayer {
  /// 애니메이션 상태 값 (0.0 ~ 1.0)
  final double animationValue;

  /// 컨테이너 크기
  final Size containerSize;

  /// 그라디언트 포인트 캐시
  List<_GradientPoint>? _gradientPointsCache;

  /// 마지막으로 사용된 컨테이너 크기
  Size? _lastContainerSize;

  /// 마지막으로 사용된 버라이어티 값
  double? _lastVariety;

  /// 마지막으로 사용된 애니메이션 값 (반올림된 값)
  double? _lastAnimationValue;

  /// 랜덤 생성기
  final _random = math.Random();

  /// 미리 정의된 하이라이트 포인트들
  late final List<_HighlightPoint> _highlightPoints;

  /// 생성자
  FullColorStyleLayer({
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

  /// 하이라이트 포인트 초기화
  void _initializeHighlightPoints() {
    _highlightPoints = [
      // 기본 상단 하이라이트 (항상 표시)
      _HighlightPoint(
        position: Offset(
          containerSize.width * 0.5,
          -containerSize.width * 0.3, // 더 위로 올림
        ),
        size: containerSize.width * 0.8, // 크기 감소
        baseOpacity: 0.45,
        varietyThreshold: 0.0,
      ),

      // 0.3 이상에서 표시되는 하이라이트들
      _HighlightPoint(
        position: Offset(
          containerSize.width * 0.85,
          containerSize.height * 0.85,
        ),
        size: containerSize.width * 0.6,
        baseOpacity: 0.4,
        varietyThreshold: 0.3,
      ),

      // 중간 영역 하이라이트들 (비대칭적 배치)
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

      // 0.7 이상에서 표시되는 하이라이트들
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

  /// 버라이어티 값에 따른 그라디언트 포인트 개수 계산
  int get _effectiveGradientPointCount {
    // variety가 0.0일 때는 기본 그라디언트 포인트 2개만 사용
    // variety가 1.0일 때는 최대 6개의 그라디언트 포인트 사용
    if (variety <= 0.0) return 2;
    return 2 + (4 * variety).round(); // 2 ~ 6개 (개수 절반으로 감소)
  }

  /// 캐시 키 생성 (애니메이션 값을 0.1 단위로 반올림)
  String _getCacheKey() {
    // 애니메이션 값을 0.1 단위로 반올림하여 캐시 키 생성
    final roundedAnimValue = (animationValue * 10).round() / 10;
    return "${containerSize.width}x${containerSize.height}_${variety}_${roundedAnimValue}";
  }

  /// 그라디언트 포인트 생성
  List<_GradientPoint> _generateGradientPoints() {
    final points = <_GradientPoint>[];
    final pointCount = _effectiveGradientPointCount;

    // 기본 그라디언트 포인트 (항상 포함)
    points.add(_generateBaseGradientPoint());

    // variety가 0보다 크면 추가 그라디언트 포인트 생성
    if (variety > 0.0 && pointCount > 2) {
      // 버라이어티에 따라 더 다양한 색상 팔레트 사용
      final colors = <Color>[];

      // 색상 특성에 따라 색상 팔레트 구성 조정
      switch (colorCharacteristic) {
        case AuraColorCharacteristic.VIVID:
          // 비비드 계열: 생생한 색상만 사용, 무채색 완전 제거
          colors.add(colorPalette.primary);
          colors.add(colorPalette.secondary);
          colors.add(colorPalette.tertiary);

          // 추가 생생한 색상 혼합
          colors.add(
              Color.lerp(colorPalette.primary, colorPalette.secondary, 0.3)!);
          colors.add(
              Color.lerp(colorPalette.secondary, colorPalette.tertiary, 0.3)!);
          colors.add(
              Color.lerp(colorPalette.tertiary, colorPalette.primary, 0.3)!);

          // 더 다양한 색상 혼합 추가
          colors.add(
              Color.lerp(colorPalette.primary, colorPalette.secondary, 0.7)!);
          colors.add(
              Color.lerp(colorPalette.secondary, colorPalette.tertiary, 0.7)!);
          colors.add(
              Color.lerp(colorPalette.tertiary, colorPalette.primary, 0.7)!);

          // 밝은 색상 추가 (비중 낮게) - 무채색 대신 색상 밝기만 조정
          if (variety > 0.5) {
            // 흰색 대신 다른 생생한 색상으로 밝기 조정
            colors.add(
                Color.lerp(colorPalette.primary, colorPalette.secondary, 0.3)!);
            colors.add(Color.lerp(
                colorPalette.secondary, colorPalette.tertiary, 0.3)!);
            colors.add(
                Color.lerp(colorPalette.tertiary, colorPalette.primary, 0.3)!);
          }
          break;

        case AuraColorCharacteristic.GRAYSCALE:
          // 무채색 계열: 무채색 위주로 구성
          colors.add(colorPalette.primary);
          colors.add(colorPalette.dark);
          colors.add(colorPalette.light);

          // 추가 무채색 혼합
          colors.add(Color.lerp(colorPalette.primary, colorPalette.dark, 0.5)!);
          colors
              .add(Color.lerp(colorPalette.primary, colorPalette.light, 0.5)!);

          // 약간의 색상 추가 (비중 낮게)
          if (variety > 0.7) {
            colors.add(colorPalette.secondary.withOpacity(0.3));
          }
          break;

        case AuraColorCharacteristic.DARK:
          // 어두운 색상 계열: 어두운 색상 위주로 구성
          colors.add(colorPalette.primary);
          colors.add(colorPalette.dark);
          colors.add(colorPalette.secondary);

          // 추가 어두운 색상 혼합
          colors.add(Color.lerp(colorPalette.primary, colorPalette.dark, 0.7)!);
          colors
              .add(Color.lerp(colorPalette.secondary, colorPalette.dark, 0.7)!);

          // 약간의 밝은 색상 추가 (비중 낮게)
          if (variety > 0.6) {
            colors.add(
                Color.lerp(colorPalette.primary, colorPalette.light, 0.2)!);
          }
          break;

        case AuraColorCharacteristic.BRIGHT:
          // 밝은 색상 계열: 밝은 색상 위주로 구성
          colors.add(colorPalette.primary);
          colors.add(colorPalette.light);
          colors.add(colorPalette.secondary);

          // 추가 밝은 색상 혼합
          colors
              .add(Color.lerp(colorPalette.primary, colorPalette.light, 0.7)!);
          colors.add(
              Color.lerp(colorPalette.secondary, colorPalette.light, 0.7)!);

          // 약간의 어두운 색상 추가 (비중 낮게)
          if (variety > 0.6) {
            colors
                .add(Color.lerp(colorPalette.primary, colorPalette.dark, 0.2)!);
          }
          break;

        case AuraColorCharacteristic.MEDIUM:
        default:
          // 중간 톤 계열: 균형 잡힌 색상 구성
          colors.add(colorPalette.primary);
          colors.add(colorPalette.secondary);
          colors.add(colorPalette.tertiary);
          colors.add(colorPalette.light);

          // 버라이어티가 높을수록 더 다양한 색상 혼합 추가
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

      // 화면을 더 균등하게 나누기 위한 그리드 설정
      // 포인트 개수가 적으므로 더 넓은 영역을 커버하도록 배치
      final gridSize = math.sqrt(pointCount).ceil();
      final cellWidth = containerSize.width / gridSize;
      final cellHeight = containerSize.height / gridSize;

      for (int i = 1; i < pointCount; i++) {
        // 색상 선택 (인덱스에 따라 다양한 색상 선택)
        // 색상 특성에 따라 색상 선택 로직 조정
        int colorIndex;

        switch (colorCharacteristic) {
          case AuraColorCharacteristic.VIVID:
            // 비비드 계열: 생생한 색상 위주로 선택 (무채색 완전 제거)
            // 항상 생생한 색상만 선택
            colorIndex = _random.nextInt(colors.length);
            break;

          case AuraColorCharacteristic.GRAYSCALE:
            // 무채색 계열: 무채색 위주로 선택
            colorIndex = _random.nextInt(colors.length);
            break;

          case AuraColorCharacteristic.DARK:
            // 어두운 색상 계열: 어두운 색상 위주로 선택
            if (_random.nextDouble() < 0.7) {
              // 70% 확률로 어두운 색상 선택 (인덱스 0~4)
              colorIndex = _random.nextInt(math.min(5, colors.length));
            } else {
              // 30% 확률로 나머지 색상 중에서 선택
              colorIndex = _random.nextInt(colors.length);
            }
            break;

          case AuraColorCharacteristic.BRIGHT:
            // 밝은 색상 계열: 밝은 색상 위주로 선택
            if (_random.nextDouble() < 0.7) {
              // 70% 확률로 밝은 색상 선택 (인덱스 0~4)
              colorIndex = _random.nextInt(math.min(5, colors.length));
            } else {
              // 30% 확률로 나머지 색상 중에서 선택
              colorIndex = _random.nextInt(colors.length);
            }
            break;

          case AuraColorCharacteristic.MEDIUM:
          default:
            // 중간 톤 계열: 버라이어티에 따라 다양한 색상 선택
            if (_random.nextDouble() < variety * 0.8) {
              // 버라이어티가 높을수록 다양한 색상 사용 확률 증가
              colorIndex = _random.nextInt(colors.length);
            } else {
              // 기본 색상 중에서 선택 (primary, secondary, tertiary, light)
              colorIndex = _random.nextInt(math.min(4, colors.length));
            }
            break;
        }

        final baseColor = colors[colorIndex];

        // 색상 특성에 따라 색상 조정
        Color gradientColor;
        double opacity;

        switch (colorCharacteristic) {
          case AuraColorCharacteristic.VIVID:
            // 비비드 계열: 원래 색상의 생생함을 최대한 유지
            gradientColor = baseColor;
            opacity = 0.3 + _random.nextDouble() * 0.2;
            break;
          case AuraColorCharacteristic.GRAYSCALE:
            // 무채색 계열: 회색조로 변환하고 약간 밝게
            final brightness = _calculateColorBrightness(baseColor);
            gradientColor = Color.fromRGBO(
              (brightness * 255).round(),
              (brightness * 255).round(),
              (brightness * 255).round(),
              1.0,
            );
            gradientColor = Color.lerp(gradientColor, colorPalette.light,
                0.1 + _random.nextDouble() * 0.2)!;
            opacity = 0.2 + _random.nextDouble() * 0.15; // 불투명도 유지
            break;
          case AuraColorCharacteristic.DARK:
            // 어두운 색상 계열: 어둡게 조정
            gradientColor = Color.lerp(baseColor, colorPalette.dark,
                0.2 + _random.nextDouble() * 0.3)!;
            opacity = 0.2 + _random.nextDouble() * 0.15; // 불투명도 유지
            break;
          case AuraColorCharacteristic.BRIGHT:
            // 밝은 색상 계열: 밝게 조정
            gradientColor = Color.lerp(baseColor, colorPalette.light,
                0.3 + _random.nextDouble() * 0.3)!;
            opacity = 0.2 + _random.nextDouble() * 0.15; // 불투명도 유지
            break;
          case AuraColorCharacteristic.MEDIUM:
          default:
            // 중간 톤 계열: 약간 밝게 조정
            gradientColor = Color.lerp(baseColor, colorPalette.light,
                0.1 + _random.nextDouble() * 0.2)!;
            opacity = 0.2 + _random.nextDouble() * 0.15; // 불투명도 유지
            break;
        }

        // 위치 계산 (그리드 기반으로 더 균등하게 분포)
        // 포인트 개수가 적으므로 화면 전체에 더 넓게 분포
        final gridX = i % gridSize;
        final gridY = i ~/ gridSize;

        // 그리드 내에서 랜덤한 위치 (완전 랜덤보다 더 균등한 분포)
        final position = Offset(
          (gridX * cellWidth) +
              (_random.nextDouble() * cellWidth * 0.8) +
              (cellWidth * 0.1),
          (gridY * cellHeight) +
              (_random.nextDouble() * cellHeight * 0.8) +
              (cellHeight * 0.1),
        );

        // 크기 계산 (화면 너비의 70%~150%)
        // 더 큰 크기로 설정하여 블러 효과가 더 넓게 퍼지도록 함
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

  /// 기본 그라디언트 포인트 생성 (상단 중앙)
  _GradientPoint _generateBaseGradientPoint() {
    // 색상 특성에 따라 그라디언트 포인트 위치와 크기 조정
    double size;
    double opacity;
    Offset position;
    Color gradientColor;

    // 애니메이션 값에 따라 크기 조정 (더 넓어지는 효과)
    final sizeMultiplier = 1.0 + (0.2 * animationValue);

    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        // 비비드 계열: 큰 그라디언트, 중간 불투명도, 생생한 색상 사용
        size = containerSize.width * 1.8 * sizeMultiplier; // 크기 유지
        opacity = 0.5 * animationValue; // 불투명도 약간 증가
        position = Offset(
          containerSize.width * 0.5,
          -size * 0.3, // 상단에 위치 유지
        );

        // 상단 하이라이트는 유지하되, 더 선명한 색상 사용
        // 원색 그대로 사용하여 생생함 극대화
        gradientColor = colorPalette.primary;
        break;
      case AuraColorCharacteristic.GRAYSCALE:
        // 무채색 계열: 작은 그라디언트, 낮은 불투명도
        size = containerSize.width * 1.5 * sizeMultiplier; // 크기 유지
        opacity = 0.35 * animationValue; // 불투명도 유지
        position = Offset(
          containerSize.width * 0.5,
          -size * 0.4, // 상단에 위치
        );
        // 어두운 색상과 밝은 색상을 혼합하여 부드러운 그라디언트 생성
        gradientColor = Color.lerp(colorPalette.light, colorPalette.dark, 0.4)!;
        break;
      case AuraColorCharacteristic.DARK:
        // 어두운 색상 계열: 중간 그라디언트, 낮은 불투명도
        size = containerSize.width * 1.6 * sizeMultiplier; // 크기 유지
        opacity = 0.35 * animationValue; // 불투명도 유지
        position = Offset(
          containerSize.width * 0.6,
          -size * 0.4, // 상단에 위치
        );
        // 주요 색상과 어두운 색상을 혼합하여 부드러운 그라디언트 생성
        gradientColor =
            Color.lerp(colorPalette.primary, colorPalette.dark, 0.3)!;
        break;
      case AuraColorCharacteristic.BRIGHT:
        // 밝은 색상 계열: 큰 그라디언트, 중간 불투명도
        size = containerSize.width * 1.7 * sizeMultiplier; // 크기 유지
        opacity = 0.4 * animationValue; // 불투명도 유지
        position = Offset(
          containerSize.width * 0.5,
          -size * 0.3, // 상단에 위치
        );
        // 주요 색상과 밝은 색상을 혼합하여 자연스러운 그라디언트 생성
        gradientColor =
            Color.lerp(colorPalette.primary, colorPalette.light, 0.5)!;
        break;
      case AuraColorCharacteristic.MEDIUM:
      default:
        // 중간 톤 계열: 중간 그라디언트, 중간 불투명도
        size = containerSize.width * 1.6 * sizeMultiplier; // 크기 유지
        opacity = 0.35 * animationValue; // 불투명도 유지
        position = Offset(
          containerSize.width * 0.5,
          -size * 0.4, // 상단에 위치
        );
        // 주요 색상과 밝은 색상을 혼합하여 자연스러운 그라디언트 생성
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

  /// 색상의 밝기 계산 (0.0 ~ 1.0)
  double _calculateColorBrightness(Color color) {
    // HSL 모델에서의 밝기 (Lightness) 계산
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;

    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));

    // HSL의 L 값 계산
    return (max + min) / 2;
  }

  /// 그라디언트 초기화
  void _initialize() {
    // 캐시 키 생성
    final cacheKey = _getCacheKey();

    // 컨테이너 크기가 변경되었거나 버라이어티 값이 변경되었거나 애니메이션 값이 크게 변경된 경우에만 그라디언트 재생성
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
    // 부모 클래스의 build 메서드 사용
    return super.build(context);
  }

  @override
  Widget buildBackgroundLayer() {
    // 애니메이션 값에 따라 그라디언트 위치 조정
    final animationOffset = Alignment(0, 0.2 - (0.2 * animationValue));

    // 팔레트 색상만 사용하여 그라디언트 생성
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
    // 색상 특성에 따라 블러 강도 조정
    double blurStrength;
    double opacityMultiplier;

    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        // 비비드 계열: 블러 최소화, 불투명도 낮게 유지
        blurStrength = math.max(1.0, blurStrengthX / 4); // 블러 더 감소
        opacityMultiplier = 0.2; // 불투명도 더 감소
        break;
      case AuraColorCharacteristic.GRAYSCALE:
        // 무채색 계열: 블러 중간, 불투명도 높게
        blurStrength = math.max(1.0, blurStrengthX / 2);
        opacityMultiplier = 0.6;
        break;
      case AuraColorCharacteristic.DARK:
        // 어두운 색상 계열: 블러 강하게, 불투명도 높게
        blurStrength = math.max(1.0, blurStrengthX / 1.5);
        opacityMultiplier = 0.7;
        break;
      case AuraColorCharacteristic.BRIGHT:
        // 밝은 색상 계열: 블러 약하게, 불투명도 중간
        blurStrength = math.max(1.0, blurStrengthX / 2.5);
        opacityMultiplier = 0.4;
        break;
      case AuraColorCharacteristic.MEDIUM:
      default:
        // 중간 톤 계열: 블러 중간, 불투명도 중간
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
          // 하이라이트 레이어
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

          // 블러 레이어
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
    // 버라이어티와 색상 특성에 따라 블렌딩 모드 조정
    BlendMode blendMode;

    // 색상 특성에 따라 블렌딩 모드 조정
    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        blendMode = BlendMode.screen; // 항상 screen 모드 사용 (더 선명하게)
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
      default:
        blendMode = variety > 0.3 ? BlendMode.softLight : BlendMode.srcOver;
        break;
    }

    // 그라디언트 포인트 그리기 (더 부드러운 효과를 위해 수정)
    for (final point in gradientPoints) {
      // 비비드 계열일 경우 블러 효과 감소
      double blurMultiplier = 1.0;
      if (colorCharacteristic == AuraColorCharacteristic.VIVID) {
        blurMultiplier = 0.7; // 블러 30% 감소
      }

      // 그라디언트 크기 계산
      final radius = point.size / 2 * (1.0 + variety * 1.0);

      // 그라디언트 위치 계산
      final center = Offset(point.position.dx, point.position.dy);

      // 그라디언트 색상 및 스톱 계산
      List<Color> colors;

      // 비비드 계열일 경우 더 선명한 색상 사용
      if (colorCharacteristic == AuraColorCharacteristic.VIVID) {
        colors = [
          point.color.withOpacity(point.opacity * 0.8), // 불투명도 증가
          point.color.withOpacity(point.opacity * 0.6), // 불투명도 증가
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

      // 버라이어티에 따라 스톱 위치 조정
      final stops = [
        0.0,
        0.2 + (variety * 0.1),
        0.4 + (variety * 0.1),
        0.7 + (variety * 0.1),
        1.0,
      ];

      // 첫 번째 그라디언트 (큰 블러)
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

      // 타원형 그라디언트 그리기
      final bigRect = Rect.fromCenter(
        center: center,
        width: radius * 3.5,
        height: radius * 3.0,
      );
      canvas.drawOval(bigRect, bigBlurPaint);

      // 두 번째 그라디언트 (중간 블러)
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
        default:
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

      // 세 번째 그라디언트 (작은 블러, 중심부 강조)
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
        default:
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

    // 버라이어티가 높을 때 추가 효과 (애플 뮤직 스타일의 미묘한 텍스처)
    if (variety > 0.3) {
      // 색상 특성에 따라 오버레이 효과 조정
      if (colorCharacteristic == AuraColorCharacteristic.VIVID) {
        // 비비드 계열: 오버레이 효과 제거 (뿌연 효과 방지)
        // 노이즈 효과도 최소화
        final random = math.Random(42); // 고정된 시드로 일관된 패턴 생성
        final pointCount =
            (size.width * size.height / 3000).round(); // 노이즈 포인트 대폭 감소

        for (int i = 0; i < pointCount; i++) {
          // 노이즈 색상도 더 선명하게
          final colorIndex = random.nextInt(gradientPoints.length);
          final noiseColor = gradientPoints[colorIndex]
              .color
              .withOpacity(0.003 * variety * animationValue); // 불투명도 감소

          final noisePaint = Paint()
            ..color = noiseColor
            ..blendMode = BlendMode.screen // 더 선명한 블렌드 모드
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.0); // 블러 감소

          final x = random.nextDouble() * size.width;
          final y = random.nextDouble() * size.height;
          final radius = 0.2 + random.nextDouble() * 0.3; // 크기 감소

          canvas.drawCircle(Offset(x, y), radius, noisePaint);
        }
      } else {
        // 다른 색상 특성: 기존 코드 유지
        final overlayPaint = Paint()
          ..color = Colors.white
              .withOpacity(0.01 * variety * animationValue) // 불투명도 감소
          ..blendMode = BlendMode.overlay;

        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

        // 미묘한 노이즈 효과 추가 (작은 점들)
        final random = math.Random(42); // 고정된 시드로 일관된 패턴 생성
        final pointCount =
            (size.width * size.height / 1200).round(); // 노이즈 포인트 감소

        final noisePaint = Paint()
          ..color = Colors.white
              .withOpacity(0.005 * variety * animationValue) // 불투명도 감소
          ..blendMode = BlendMode.overlay
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, 2.0); // 노이즈에도 약간의 블러 추가

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
      BlendMode blendMode = BlendMode.srcOver; // 기본 블렌드 모드로 변경

      // 위치에 따른 색상 선택 로직 수정
      if (point.position.dy < 0) {
        // 상단 하이라이트
        gradientColor = colorPalette.primary;
        blurStrength = 20.0;
      } else if (point.position.dy > size.height * 0.7) {
        // 하단 하이라이트
        gradientColor = colorPalette.primary;
        blurStrength = 25.0;
      } else {
        // 중간 영역 하이라이트 - 팔레트 색상만 활용
        final horizontalPosition = point.position.dx / size.width;
        final verticalPosition = point.position.dy / size.height;

        // 위치에 따른 색상 믹스
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

      // 비정형 형태를 위한 여러 레이어의 그라디언트
      for (int i = 0; i < 3; i++) {
        // 각 레이어별 색상 조정 - 팔레트 색상만 활용
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

        // 그라디언트 색상 - 투명도만 조정
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

        // 비정형 형태 생성
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

/// 주어진 기준 색상과 가장 대비되는 색상을 반환
Color _getContrastColor({
  required Color baseColor,
  required Color option1,
  required Color option2,
}) {
  // HSV 색상 공간에서의 색상(Hue) 차이를 계산
  final baseHSV = _colorToHSV(baseColor);
  final option1HSV = _colorToHSV(option1);
  final option2HSV = _colorToHSV(option2);

  // 색상환에서의 거리 계산 (0-360도)
  final diff1 = _calculateHueDistance(baseHSV[0], option1HSV[0]);
  final diff2 = _calculateHueDistance(baseHSV[0], option2HSV[0]);

  // 채도(Saturation)와 명도(Value) 차이도 고려
  final satDiff1 = (baseHSV[1] - option1HSV[1]).abs();
  final satDiff2 = (baseHSV[1] - option2HSV[1]).abs();
  final valDiff1 = (baseHSV[2] - option1HSV[2]).abs();
  final valDiff2 = (baseHSV[2] - option2HSV[2]).abs();

  // 종합적인 대비 점수 계산
  final score1 = diff1 * 0.6 + satDiff1 * 0.2 + valDiff1 * 0.2;
  final score2 = diff2 * 0.6 + satDiff2 * 0.2 + valDiff2 * 0.2;

  // 더 높은 대비 점수를 가진 색상 반환
  return score1 > score2 ? option1 : option2;
}

/// RGB 색상을 HSV로 변환
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

/// 두 색상(Hue) 간의 거리 계산
double _calculateHueDistance(double hue1, double hue2) {
  final diff = (hue1 - hue2).abs();
  return math.min(diff, 360 - diff) / 180.0; // 0-1 범위로 정규화
}
