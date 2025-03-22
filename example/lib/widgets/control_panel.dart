import 'package:flutter/material.dart';
import 'package:adaptive_aura/adaptive_aura.dart';

/// Control panel widget for adjusting app settings
class ControlPanel extends StatefulWidget {
  /// Current animation value (0.0 ~ 1.0)
  final double animationValue;

  /// Current aura style
  final AuraStyle auraStyle;

  /// Whether to use custom blur
  final bool useCustomBlur;

  /// Blur strength (single value)
  final double blurStrength;

  /// X-axis blur strength
  final double? blurStrengthX;

  /// Y-axis blur strength
  final double? blurStrengthY;

  /// Blur layer opacity
  final double blurLayerOpacity;

  /// Variety value (0.0 ~ 1.0)
  final double variety;

  /// Current color palette
  final AuraColorPalette? currentPalette;

  /// Animation value change callback
  final ValueChanged<double> onAnimationValueChanged;

  /// Aura style change callback
  final ValueChanged<AuraStyle> onAuraStyleChanged;

  /// Custom blur usage change callback
  final ValueChanged<bool> onUseCustomBlurChanged;

  /// Blur strength change callback
  final ValueChanged<double> onBlurStrengthChanged;

  /// X-axis blur strength change callback
  final ValueChanged<double> onBlurStrengthXChanged;

  /// Y-axis blur strength change callback
  final ValueChanged<double> onBlurStrengthYChanged;

  /// Blur layer opacity change callback
  final ValueChanged<double> onBlurLayerOpacityChanged;

  /// Variety value change callback
  final ValueChanged<double> onVarietyChanged;

  /// Constructor
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
  // Local state variables
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
    // Set initial values
    _animationValue = widget.animationValue;
    _auraStyle = widget.auraStyle;
    _useCustomBlur = widget.useCustomBlur;
    _blurStrength = widget.blurStrength;
    _blurStrengthX = widget.blurStrengthX ?? 20.0; // Set default value
    _blurStrengthY = widget.blurStrengthY ?? 20.0; // Set default value
    _blurLayerOpacity = widget.blurLayerOpacity;
    _variety = widget.variety;
  }

  @override
  void didUpdateWidget(ControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update values when widget updates
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
                      case AuraStyle.blob:
                        displayName = 'Blob Style';
                        break;
                      case AuraStyle.gradient:
                        displayName = 'Gradient Style';
                        break;
                      case AuraStyle.sunray:
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

  /// Create color swatch widget
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
