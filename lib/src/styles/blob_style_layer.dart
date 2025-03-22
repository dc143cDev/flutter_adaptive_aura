import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'aura_style_layer.dart';
import '../models/aura_color_palette.dart';

/// 랜덤 값들을 저장하는 전역 클래스
/// 이를 통해 위젯이 리빌드되어도 랜덤 값들이 유지됩니다.
class _BlobStyleConfig {
  static final _BlobStyleConfig _instance = _BlobStyleConfig._internal();

  factory _BlobStyleConfig() {
    return _instance;
  }

  _BlobStyleConfig._internal() {
    _initialize();
  }

  /// 랜덤 생성기
  final _random = math.Random();

  /// 블롭 위치 오프셋 (랜덤 생성)
  late final List<Offset> blobOffsets;

  /// 블롭 크기 (랜덤 생성)
  late final List<double> blobSizes;

  /// 블롭 회전 각도 (랜덤 생성)
  late final List<double> blobRotations;

  /// 블롭 이동 방향 및 거리 (랜덤 생성)
  late final List<Offset> blobMovementVectors;

  /// 작은 포인트 이동 방향 및 거리 (랜덤 생성)
  late final List<Offset> smallBlobMovementVectors;

  /// 작은 포인트 위치 (랜덤 생성)
  late final List<Offset> smallBlobOffsets;

  /// 작은 포인트 크기 (랜덤 생성)
  late final List<double> smallBlobSizes;

  /// 작은 포인트 회전 (랜덤 생성)
  late final List<double> smallBlobRotations;

  /// 초기화 여부
  bool _isInitialized = false;

  /// 최대 블롭 개수
  static const int maxBlobCount = 100;

  /// 최대 작은 포인트 개수
  static const int maxSmallBlobCount = 200;

  /// 기본 블롭 개수
  static const int defaultBlobCount = 18;

  /// 기본 작은 포인트 개수
  static const int defaultSmallBlobCount = 20;

  void _initialize() {
    if (_isInitialized) return;

    // 최대 개수로 리스트 초기화
    // 블롭 이동 벡터 생성 (이동 거리: 6~16픽셀)
    blobMovementVectors = List.generate(maxBlobCount,
        (_) => _generateRandomMovementVector(minDistance: 6, maxDistance: 16));

    // 작은 포인트 이동 벡터 생성 (이동 거리: 4~10픽셀)
    smallBlobMovementVectors = List.generate(maxSmallBlobCount,
        (_) => _generateRandomMovementVector(minDistance: 4, maxDistance: 10));

    // 랜덤 블롭 위치, 크기, 회전 생성
    blobOffsets = List.generate(maxBlobCount, (_) => _randomOffset());
    blobSizes = List.generate(maxBlobCount, (_) => _randomSize());
    blobRotations = List.generate(maxBlobCount, (_) => _randomRotation());

    // 작은 포인트 위치, 크기, 회전 생성
    smallBlobOffsets = List.generate(maxSmallBlobCount, (_) => _randomOffset());
    smallBlobSizes =
        List.generate(maxSmallBlobCount, (_) => _randomSmallSize());
    smallBlobRotations =
        List.generate(maxSmallBlobCount, (_) => _randomRotation());

    _isInitialized = true;
  }

  /// 무작위 이동 벡터 생성 (지정된 범위 내의 거리와 무작위 방향)
  Offset _generateRandomMovementVector(
      {double minDistance = 6, double maxDistance = 16}) {
    // 무작위 거리 (기본값: 6~16픽셀)
    final distance =
        minDistance + _random.nextDouble() * (maxDistance - minDistance);

    // 무작위 각도 (0~2π)
    final angle = _random.nextDouble() * 2 * math.pi;

    // 극좌표를 직교좌표로 변환
    return Offset(
      distance * math.cos(angle),
      distance * math.sin(angle),
    );
  }

  /// 랜덤 오프셋 생성 (-0.8 ~ 0.8 범위)
  Offset _randomOffset() {
    return Offset(
      _random.nextDouble() * 1.6 - 0.8,
      _random.nextDouble() * 1.6 - 0.8,
    );
  }

  /// 랜덤 크기 생성 (100 ~ 350 범위)
  double _randomSize() {
    return 100.0 + _random.nextDouble() * 250.0;
  }

  /// 랜덤 작은 크기 생성 (20 ~ 60 범위)
  double _randomSmallSize() {
    return 20.0 + _random.nextDouble() * 40.0;
  }

  /// 랜덤 회전 생성 (0 ~ 2π 범위)
  double _randomRotation() {
    return _random.nextDouble() * 2 * math.pi;
  }
}

/// 블롭 정보를 저장하는 클래스
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

/// 블롭 스타일의 레이어 구현체
class BlobStyleLayer extends AuraStyleLayer {
  /// 애니메이션 상태 값 (0.0 ~ 1.0)
  final double animationValue;

  /// 컨테이너 크기
  final Size containerSize;

  /// 공유 설정 인스턴스
  final _config = _BlobStyleConfig();

  /// 블러 효과 사용 여부
  bool get _useBlurEffect => blurStrengthX > 0.0 || blurStrengthY > 0.0;

  /// 생성자
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

  /// 버라이어티 값에 따른 실제 블롭 개수 계산
  int get _effectiveBlobCount {
    final minCount = 5;
    final maxCount = _BlobStyleConfig.maxBlobCount;
    return minCount + ((maxCount - minCount) * variety).round();
  }

  /// 버라이어티 값에 따른 실제 작은 블롭 개수 계산
  int get _effectiveSmallBlobCount {
    final minCount = 10;
    final maxCount = _BlobStyleConfig.maxSmallBlobCount;
    return minCount + ((maxCount - minCount) * variety).round();
  }

  /// 애니메이션 값에 따른 펄스 스케일 계산
  double _calculatePulseScale(int index) {
    // 기본 스케일 (0.99 ~ 1.01)
    final baseScale = 0.99 + (0.02 * animationValue);

    // 각 블롭마다 약간 다른 스케일 적용
    final randomOffset = (index % 5) * 0.002 * animationValue;

    return baseScale + randomOffset;
  }

  /// 애니메이션 값에 따른 이동 오프셋 계산
  Offset _calculateMovementOffset(Offset vector, int index) {
    // 각 블롭마다 약간 다른 진행 속도 적용
    final progress = (animationValue + (index % 7) * 0.1) % 1.0;

    // 사인 곡선을 사용하여 부드러운 왕복 움직임 구현
    final factor = math.sin(progress * math.pi) * animationValue;

    return Offset(vector.dx * factor, vector.dy * factor);
  }

  @override
  Widget build(BuildContext context) {
    // 부모 클래스의 build 메서드 사용
    return super.build(context);
  }

  @override
  Widget buildBackgroundLayer() {
    // 색상 특성에 따른 배경 설정 가져오기
    final settings = getBackgroundSettingsForCharacteristic();

    // 배경 색상 선택 (밝은 색상과 주요 색상의 혼합)
    final backgroundColor1 = Color.lerp(
        colorPalette.light,
        colorPalette.primary.withOpacity(settings.primaryOpacity),
        math.max(0.0, 1.0 - settings.lightColorWeight))!;

    final backgroundColor2 = Color.lerp(
        colorPalette.light,
        colorPalette.secondary.withOpacity(settings.secondaryOpacity),
        math.max(0.0, 0.9 - settings.lightColorWeight))!;

    // 배경 그라데이션 생성
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
    // 블러 강도가 0.0인 경우 블러 효과를 적용하지 않음
    if (!_useBlurEffect) {
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
    // animationValue가 0이면 빈 컨테이너 반환
    if (animationValue <= 0.01) {
      return Container();
    }

    // 컨테이너 크기가 유효한지 확인
    final hasValidSize = containerSize.width > 0 && containerSize.height > 0;
    if (!hasValidSize) {
      return Container();
    }

    // 모든 블롭 정보를 생성하고 크기에 따라 정렬 (작은 것부터)
    List<_BlobInfo> allBlobs = [];

    // 메인 블롭 추가
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

    // 버라이어티 값에 따른 실제 블롭 개수 계산
    final blobCount = _effectiveBlobCount;
    final smallBlobCount = _effectiveSmallBlobCount;

    // 일반 블롭 추가
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

    // 작은 블롭 추가
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

    // 크기에 따라 정렬 (작은 것부터 큰 것 순으로)
    allBlobs.sort((a, b) => a.size.compareTo(b.size));

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: allBlobs.map((blob) {
          // 블롭 크기에 따른 블러 강도 계산
          final maxSize =
              math.min(containerSize.width, containerSize.height) * 0.6;
          final sizeRatio = blob.size / maxSize;

          // 블러 강도 계산 - 정말 작은 블롭에만 블러 적용 (기본값)
          double blurFactor;
          if (sizeRatio < 0.15) {
            // 아주 작은 블롭 (크기 비율 15% 미만) - 강한 블러 적용
            blurFactor = 0.5;
          } else if (sizeRatio < 0.25) {
            // 작은 블롭 (크기 비율 15%~25%) - 약한 블러 적용
            blurFactor = 0.2;
          } else {
            // 중간~큰 블롭 (크기 비율 25% 이상) - 기본적으로 블러 없음
            blurFactor = 0.0;
          }

          // 사용자가 블러 강도를 설정한 경우 추가 블러 적용
          if (_useBlurEffect) {
            // 블러 강도에 따른 추가 블러 적용 로직 (최대 강도를 낮춤)
            final blurStrengthRatio = math.max(blurStrengthX, blurStrengthY) /
                20.0; // 0.0 ~ 0.5 범위로 정규화

            if (blurStrengthRatio > 0.1) {
              // 블러 강도가 중간 이상인 경우
              if (sizeRatio < 0.4) {
                // 작은~중간 블롭에 추가 블러 적용 (강도 감소)
                blurFactor = math.max(
                    blurFactor, (1.0 - sizeRatio) * 0.3 * blurStrengthRatio);
              } else if (blurStrengthRatio > 0.3) {
                // 블러 강도가 높고 큰 블롭인 경우에도 매우 약한 블러 적용
                blurFactor = math.max(blurFactor, 0.05 * blurStrengthRatio);
              }
            }

            // 블러 강도가 최대치에 가까울 때 모든 블롭에 약한 블러 적용
            if (blurStrengthRatio > 0.4) {
              // 크기에 반비례하는 블러 강도 적용 (작을수록 강한 블러, 전체적으로 강도 감소)
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
            blurFactor: blurFactor, // 크기에 따른 블러 강도 전달
          );
        }).toList(),
      ),
    );
  }

  /// 아우라 블롭 위젯 생성
  Widget _buildAuraBlob({
    required double scale,
    required Offset movementOffset,
    required Color color,
    required double size,
    required Offset offset,
    required double rotation,
    required int index,
    required double blurFactor, // 블러 강도 계수 추가
  }) {
    // 애니메이션 값이 0이면 빈 컨테이너 반환
    if (animationValue <= 0.01) {
      return Container();
    }

    // 기본 위치 계산
    return Positioned.fill(
      child: Center(
        child: Builder(
          builder: (context) {
            // 컨테이너 크기 사용
            final screenSize = containerSize;

            // 화면 크기가 유효한지 확인
            final hasValidSize = screenSize.width > 0 && screenSize.height > 0;
            if (!hasValidSize) {
              return Container(); // 유효한 크기가 없으면 빈 컨테이너 반환
            }

            // 기본 위치 계산 (컨테이너 내부로 제한)
            final baseOffset = Offset(
              screenSize.width * offset.dx,
              screenSize.height * offset.dy,
            );

            // 최종 위치 계산
            final finalOffset = baseOffset + movementOffset;

            // 스케일이 유효한지 확인 (0이 아닌지)
            final validScale = scale.isFinite && scale != 0;

            // 블롭 위젯 생성 - 블러 강도에 따라 스타일 결정
            Widget blobWidget;

            if (blurFactor <= 0.01) {
              // 블러 없는 블롭 (중간~큰 블롭)
              blobWidget = Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(colorIntensity * animationValue),
                ),
              );
            } else {
              // 블러 있는 블롭 (작은 블롭 또는 블러 강도가 높은 경우)
              final isSmallBlob = size /
                      (math.min(containerSize.width, containerSize.height) *
                          0.6) <
                  0.25;

              // 작은 블롭은 그라데이션, 큰 블롭은 단색으로 처리
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

              // 블러 효과 적용 (강도 감소)
              final baseBlur = math.min(1.5, blurFactor * 1.5); // 기본 블러 강도 감소
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
                  scale: validScale ? scale : 1.0, // 유효하지 않은 스케일 값 처리
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
