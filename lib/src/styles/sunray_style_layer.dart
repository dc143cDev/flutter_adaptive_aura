import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'aura_style_layer.dart';
import '../models/aura_color_palette.dart';

/// 선레이 스타일의 레이어 구현체
class SunrayStyleLayer extends AuraStyleLayer {
  /// 애니메이션 상태 값 (0.0 ~ 1.0)
  final double animationValue;

  /// 컨테이너 크기
  @override
  final Size containerSize;

  /// 랜덤 생성기
  final _random = math.Random();

  /// 생성자
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

  /// 버라이어티 값에 따른 실제 광선 개수 계산
  int get _effectiveRayCount {
    // 광선 개수를 버라이어티에 따라 역으로 조정
    // 버라이어티가 낮을수록 많은 광선 (더 얇고 촘촘한 광선)
    final maxRayCount = 100; // 버라이어티 0.0일 때 최대 광선 수
    final minRayCount = 36; // 버라이어티 1.0일 때 최소 광선 수 (더 넓고 적은 광선)

    final count = maxRayCount - ((maxRayCount - minRayCount) * variety).round();
    return (count ~/ 4) * 4; // 4의 배수로 조정
  }

  /// 버라이어티 값에 따른 실제 광선 두께 계산
  double get _effectiveRayThickness {
    // 버라이어티에 따라 두께 증가 - 극단적으로 얇은 시작점으로 조정
    final minThickness = 0.05; // 버라이어티 0.0 상태의 두께 (극단적으로 얇게)
    final maxThickness = 45.0; // 버라이어티 1.0 상태의 두께

    // 처음 0.1 구간에서 급격히 두꺼워지고, 그 이후로는 더 완만하게 증가
    if (variety < 0.1) {
      // 0.0~0.1 구간에서 더 급격하게 증가 (0.05에서 시작해서 약 5.0까지)
      return minThickness + ((5.0 - minThickness) * (variety / 0.1));
    } else {
      // 0.1 이후부터는 기존처럼 선형적으로 증가
      return 5.0 + ((maxThickness - 5.0) * ((variety - 0.1) / 0.9));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 부모 클래스의 build 메서드 사용
    return super.build(context);
  }

  @override
  Widget buildBackgroundLayer() {
    // 배경 불투명도 줄여서 더 밝게 설정
    double opacity = math.min(1.0, animationValue * (0.2 + variety * 0.4));

    return Container(
      color: colorPalette.dark.withOpacity(opacity),
    );
  }

  @override
  Widget buildBlurLayer() {
    // 블러 강도가 0.0인 경우 블러 효과를 적용하지 않음
    if (blurStrengthX <= 0.0 && blurStrengthY <= 0.0) {
      return Container(
        color: Colors.black.withOpacity(blurLayerOpacity),
      );
    }

    // 일반적인 블러 효과 적용
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

    // 광선 그리기 - 블러는 전체 레이어에 적용
    return BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: math.min(10.0, blurStrengthX * 0.2), // 안전한 범위로 제한
        sigmaY: math.min(10.0, blurStrengthY * 0.2), // 안전한 범위로 제한
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
          blurStrengthX: 0, // 개별 광선에는 블러를 적용하지 않음
          blurStrengthY: 0, // 개별 광선에는 블러를 적용하지 않음
        ),
      ),
    );
  }
}

/// 선레이를 그리는 커스텀 페인터
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
  final _random = math.Random(42); // 고정된 시드로 일관된 패턴 생성

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
    // 캔버스 중심
    final center = Offset(size.width / 2, size.height / 2);

    // 대각선 길이 (화면의 모서리까지의 거리)
    final diagonalLength =
        math.sqrt(size.width * size.width + size.height * size.height);

    // 사용할 색상 목록 준비
    final colors = _prepareColors();

    // 각 광선의 각도 간격
    final double angleStep = 2 * math.pi / rayCount;

    // 애니메이션 각도 오프셋 (회전 효과)
    final angleOffset = animationValue * 0.05 * math.pi;

    // 모든 광선 그리기
    for (int i = 0; i < rayCount; i++) {
      // 현재 광선의 각도
      final angle = i * angleStep + angleOffset;

      // 광선 끝점 계산
      final rayEnd = Offset(
        center.dx + diagonalLength * math.cos(angle),
        center.dy + diagonalLength * math.sin(angle),
      );

      // 현재 광선의 색상 선택 (색상 목록에서 순환)
      final baseColor = colors[i % colors.length];

      // 광선 그리기
      _drawRay(canvas, center, rayEnd, baseColor, i);
    }
  }

  /// 사용할 색상 목록 준비
  List<Color> _prepareColors() {
    final List<Color> colors = [];

    // 색상 특성에 따라 색상 조정 - 더 밝은 색상으로 조정
    switch (colorCharacteristic) {
      case AuraColorCharacteristic.VIVID:
        // 비비드 계열: 더 선명하고 밝은 원색 위주
        colors.add(colorPalette.primary);
        colors.add(colorPalette.secondary);
        colors.add(colorPalette.tertiary);
        // 더 밝은 색상 추가
        colors.add(Color.lerp(colorPalette.primary, Colors.white, 0.2)!);
        colors.add(Color.lerp(colorPalette.secondary, Colors.white, 0.2)!);
        colors.add(Color.lerp(colorPalette.tertiary, Colors.white, 0.2)!);
        break;

      case AuraColorCharacteristic.GRAYSCALE:
        // 무채색 계열: 매우 밝은 흑백 그라데이션
        colors.add(Colors.white);
        colors.add(Color.lerp(Colors.white, Colors.grey, 0.2)!);
        colors.add(Color.lerp(Colors.white, Colors.grey, 0.4)!);
        colors.add(Colors.grey[300]!);
        colors.add(Colors.grey[500]!);
        colors.add(Colors.grey[700]!);
        break;

      case AuraColorCharacteristic.DARK:
        // 어두운 색상 계열: 기존보다 더 밝게 조정
        colors.add(colorPalette.primary);
        colors.add(colorPalette.secondary);
        colors.add(colorPalette.tertiary);
        colors.add(Color.lerp(colorPalette.primary, Colors.black, 0.2)!);
        colors.add(Color.lerp(colorPalette.secondary, Colors.black, 0.2)!);
        colors.add(Color.lerp(colorPalette.tertiary, Colors.black, 0.2)!);
        break;

      case AuraColorCharacteristic.BRIGHT:
        // 밝은 색상 계열: 매우 밝게
        colors.add(colorPalette.primary);
        colors.add(colorPalette.secondary);
        colors.add(colorPalette.tertiary);
        colors.add(Color.lerp(colorPalette.primary, Colors.white, 0.5)!);
        colors.add(Color.lerp(colorPalette.secondary, Colors.white, 0.5)!);
        colors.add(Color.lerp(colorPalette.tertiary, Colors.white, 0.5)!);
        break;

      case AuraColorCharacteristic.MEDIUM:
      default:
        // 중간 톤 계열: 더 밝게 조정
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

  /// 광선 그리기
  void _drawRay(Canvas canvas, Offset center, Offset rayEnd, Color baseColor,
      int rayIndex) {
    // 원뿔(콘) 형태로 그리기 위한 각도 계산
    final double angle =
        math.atan2(rayEnd.dy - center.dy, rayEnd.dx - center.dx);
    final double distance = (center - rayEnd).distance;

    // 버라이어티에 따라 광선 너비 조정 (더 넓은 부채꼴 형태)
    final double fanAngle = math.pi / rayCount * (1.0 + variety * 3.0);

    // 부채꼴 경로 생성
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

    // 색상 특성에 따른 불투명도 조정
    final opacityMultiplier =
        colorCharacteristic == AuraColorCharacteristic.VIVID
            ? 2.0
            : colorCharacteristic == AuraColorCharacteristic.BRIGHT
                ? 1.8
                : colorCharacteristic == AuraColorCharacteristic.MEDIUM
                    ? 1.5
                    : 1.2;

    // 기본 불투명도 값 (전체적으로 밝게)
    final baseOpacity = 0.5;
    final tailOpacity = 0.2;

    // 그라데이션 생성 (밝고 선명한 색감)
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

    // 개별 광선에는 블러를 적용하지 않음 (전체 레이어에 블러 적용)

    // 부채꼴 그리기
    canvas.drawPath(path, fanPaint);

    // 버라이어티가 높을 때 추가적인 중심 광선 추가 (중앙 밝은 부분)
    if (variety > 0.1) {
      // 더 낮은 버라이어티에서도 중심 광선 표시
      // 버라이어티가 낮을 때는 더 얇은 선으로 시작
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

      // 개별 광선에는 블러를 적용하지 않음 (전체 레이어에 블러 적용)

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
