import 'package:flutter/material.dart';
import 'package:adaptive_aura/adaptive_aura.dart';

/// 앱 설정을 조정할 수 있는 컨트롤 패널 위젯
class ControlPanel extends StatefulWidget {
  /// 현재 애니메이션 값 (0.0 ~ 1.0)
  final double animationValue;

  /// 현재 아우라 스타일
  final AuraStyle auraStyle;

  /// 커스텀 블러 사용 여부
  final bool useCustomBlur;

  /// 블러 강도 (단일 값)
  final double blurStrength;

  /// X축 블러 강도
  final double? blurStrengthX;

  /// Y축 블러 강도
  final double? blurStrengthY;

  /// 블러 레이어 불투명도
  final double blurLayerOpacity;

  /// 다양성 값 (0.0 ~ 1.0)
  final double variety;

  /// 현재 색상 팔레트
  final AuraColorPalette? currentPalette;

  /// 애니메이션 값 변경 콜백
  final ValueChanged<double> onAnimationValueChanged;

  /// 아우라 스타일 변경 콜백
  final ValueChanged<AuraStyle> onAuraStyleChanged;

  /// 커스텀 블러 사용 여부 변경 콜백
  final ValueChanged<bool> onUseCustomBlurChanged;

  /// 블러 강도 변경 콜백
  final ValueChanged<double> onBlurStrengthChanged;

  /// X축 블러 강도 변경 콜백
  final ValueChanged<double> onBlurStrengthXChanged;

  /// Y축 블러 강도 변경 콜백
  final ValueChanged<double> onBlurStrengthYChanged;

  /// 블러 레이어 불투명도 변경 콜백
  final ValueChanged<double> onBlurLayerOpacityChanged;

  /// 다양성 값 변경 콜백
  final ValueChanged<double> onVarietyChanged;

  /// 생성자
  const ControlPanel({
    super.key,
    required this.animationValue,
    required this.auraStyle,
    required this.useCustomBlur,
    required this.blurStrength,
    this.blurStrengthX,
    this.blurStrengthY,
    required this.blurLayerOpacity,
    required this.variety,
    required this.currentPalette,
    required this.onAnimationValueChanged,
    required this.onAuraStyleChanged,
    required this.onUseCustomBlurChanged,
    required this.onBlurStrengthChanged,
    required this.onBlurStrengthXChanged,
    required this.onBlurStrengthYChanged,
    required this.onBlurLayerOpacityChanged,
    required this.onVarietyChanged,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  // 로컬 상태 변수들
  late double _animationValue;
  late AuraStyle _auraStyle;
  late bool _useCustomBlur;
  late double _blurStrength;
  late double _blurStrengthX;
  late double _blurStrengthY;
  late double _blurLayerOpacity;
  late double _variety;

  @override
  void initState() {
    super.initState();
    // 초기값 설정
    _animationValue = widget.animationValue;
    _auraStyle = widget.auraStyle;
    _useCustomBlur = widget.useCustomBlur;
    _blurStrength = widget.blurStrength;
    _blurStrengthX = widget.blurStrengthX ?? 20.0; // 기본값 설정
    _blurStrengthY = widget.blurStrengthY ?? 20.0; // 기본값 설정
    _blurLayerOpacity = widget.blurLayerOpacity;
    _variety = widget.variety;
  }

  @override
  void didUpdateWidget(ControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯이 업데이트되면 값 갱신
    if (oldWidget.animationValue != widget.animationValue) {
      _animationValue = widget.animationValue;
    }
    if (oldWidget.auraStyle != widget.auraStyle) {
      _auraStyle = widget.auraStyle;
    }
    if (oldWidget.useCustomBlur != widget.useCustomBlur) {
      _useCustomBlur = widget.useCustomBlur;
    }
    if (oldWidget.blurStrength != widget.blurStrength) {
      _blurStrength = widget.blurStrength;
    }
    if (oldWidget.blurStrengthX != widget.blurStrengthX &&
        widget.blurStrengthX != null) {
      _blurStrengthX = widget.blurStrengthX!;
    }
    if (oldWidget.blurStrengthY != widget.blurStrengthY &&
        widget.blurStrengthY != null) {
      _blurStrengthY = widget.blurStrengthY!;
    }
    if (oldWidget.blurLayerOpacity != widget.blurLayerOpacity) {
      _blurLayerOpacity = widget.blurLayerOpacity;
    }
    if (oldWidget.variety != widget.variety) {
      _variety = widget.variety;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bottom sheet handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),

                // Title
                const Text(
                  'Control Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 20),

                // Animation value slider
                const Text(
                  'Animation Value:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Intensity:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: Slider(
                        value: _animationValue,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        label: _animationValue.toStringAsFixed(2),
                        onChanged: (value) {
                          setState(() {
                            _animationValue = value;
                          });
                          widget.onAnimationValueChanged(value);
                        },
                      ),
                    ),
                    Text(
                      _animationValue.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Variety slider
                const Text(
                  'Variety:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Complexity:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: Slider(
                        value: _variety,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        label: _variety.toStringAsFixed(2),
                        onChanged: (value) {
                          setState(() {
                            _variety = value;
                          });
                          widget.onVarietyChanged(value);
                        },
                      ),
                    ),
                    Text(
                      _variety.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Aura style selection
                const Text(
                  'Aura Style:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<AuraStyle>(
                  value: _auraStyle,
                  dropdownColor: Colors.black87,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onChanged: (AuraStyle? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _auraStyle = newValue;
                      });
                      widget.onAuraStyleChanged(newValue);
                    }
                  },
                  items: AuraStyle.values
                      .map<DropdownMenuItem<AuraStyle>>((AuraStyle value) {
                    String displayName = '';
                    switch (value) {
                      case AuraStyle.BLOB:
                        displayName = 'Blob Style';
                        break;
                      case AuraStyle.FULL_COLOR:
                        displayName = 'Full Color Style';
                        break;
                      case AuraStyle.SUNRAY:
                        displayName = 'Sunray Style';
                        break;
                    }
                    return DropdownMenuItem<AuraStyle>(
                      value: value,
                      child: Text(displayName),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Note: Blur settings can be automatically applied based on aura style,
                // but we keep the controls for user customization.
                const Text(
                  'Blur Settings (Style Customization):',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                // Blur mode selection
                Row(
                  children: [
                    const Text(
                      'Custom Blur (X/Y Separate):',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _useCustomBlur,
                      onChanged: (value) {
                        setState(() {
                          _useCustomBlur = value;
                        });
                        widget.onUseCustomBlurChanged(value);
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),

                // Regular blur strength slider
                if (!_useCustomBlur) ...[
                  Row(
                    children: [
                      const Text(
                        'Blur Strength:',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: _blurStrength,
                          min: 0,
                          max: 50,
                          divisions: 50,
                          label: _blurStrength.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _blurStrength = value;
                            });
                            widget.onBlurStrengthChanged(value);
                          },
                        ),
                      ),
                      Text(
                        _blurStrength.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ] else ...[
                  // X-axis blur strength slider
                  Row(
                    children: [
                      const Text(
                        'X-axis Blur:',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: _blurStrengthX,
                          min: 0,
                          max: 50,
                          divisions: 50,
                          label: _blurStrengthX.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _blurStrengthX = value;
                            });
                            widget.onBlurStrengthXChanged(value);
                          },
                        ),
                      ),
                      Text(
                        _blurStrengthX.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  // Y-axis blur strength slider
                  Row(
                    children: [
                      const Text(
                        'Y-axis Blur:',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: _blurStrengthY,
                          min: 0,
                          max: 50,
                          divisions: 50,
                          label: _blurStrengthY.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _blurStrengthY = value;
                            });
                            widget.onBlurStrengthYChanged(value);
                          },
                        ),
                      ),
                      Text(
                        _blurStrengthY.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],

                // Blur layer opacity slider
                Row(
                  children: [
                    const Text(
                      'Blur Layer Opacity:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: Slider(
                        value: _blurLayerOpacity,
                        min: 0,
                        max: 0.5,
                        divisions: 50,
                        label: _blurLayerOpacity.toStringAsFixed(2),
                        onChanged: (value) {
                          setState(() {
                            _blurLayerOpacity = value;
                          });
                          widget.onBlurLayerOpacityChanged(value);
                        },
                      ),
                    ),
                    Text(
                      _blurLayerOpacity.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Current palette information
                if (widget.currentPalette != null) ...[
                  const Text(
                    'Extracted Color Palette:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorSwatch(
                          'Primary', widget.currentPalette!.primary),
                      _buildColorSwatch(
                          'Secondary', widget.currentPalette!.secondary),
                      _buildColorSwatch(
                          'Tertiary', widget.currentPalette!.tertiary),
                      _buildColorSwatch('Light', widget.currentPalette!.light),
                      _buildColorSwatch('Dark', widget.currentPalette!.dark),
                    ],
                  ),
                ],

                const SizedBox(height: 30),

                // Instructions
                const Text(
                  'Instructions:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Touch and hold the album cover to activate the aura effect\n'
                  '• Use the slider to adjust the animation intensity\n'
                  '• Adjust the variety slider to control the complexity of effects\n'
                  '• Try different aura styles and blur settings\n'
                  '• Press the refresh button to change the album image',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 색상 스와치 위젯 생성
  Widget _buildColorSwatch(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}
