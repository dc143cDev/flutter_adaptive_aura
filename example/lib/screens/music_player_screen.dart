import 'package:flutter/material.dart';
import 'package:adaptive_aura/adaptive_aura.dart';
import '../widgets/control_panel.dart';
import '../models/album_info.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with TickerProviderStateMixin {
  // Test album list
  final List<AlbumInfo> _albums = [
    AlbumInfo(
      title: 'Hurry Up Tommorow',
      artist: 'The Weeknd',
      image: const AssetImage('assets/images/album_test01.webp'),
    ),
    AlbumInfo(
      title: 'Geography',
      artist: 'Tom Misch',
      image: const AssetImage('assets/images/album_test02.png'),
    ),
    AlbumInfo(
      title: 'Californication',
      artist: 'Red Hot Chili Peppers',
      image: const AssetImage('assets/images/album_test03.png'),
    ),
    AlbumInfo(
      title: 'ColorVision',
      artist: 'Max',
      image: const AssetImage('assets/images/album_test04.png'),
    ),
    AlbumInfo(
      title: 'AM',
      artist: 'Arctic Monkeys',
      image: const AssetImage('assets/images/album_test05.png'),
    ),
  ];

  int _currentAlbumIndex = 0;
  AuraColorPalette? _currentPalette;

  // Playing state
  bool _isPlaying = false;

  // Blur settings
  double _blurStrength = 20.0;
  double _blurLayerOpacity = 0.1;
  bool _useCustomBlur = false;
  double _blurStrengthX = 20.0;
  double _blurStrengthY = 20.0;

  // Aura style settings
  AuraStyle _auraStyle = AuraStyle.FULL_COLOR;

  // Animation value (0.0 ~ 1.0)
  double _animationValue = 0.7;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Interaction variables
  bool _isPressed = false;
  bool _isAnimating = false; // Animation progress tracking
  final double _minAnimationValue = 0.3;
  final double _maxAnimationValue = 1.0;
  final double _fixedAnimationValue = 0.7;
  final Duration _pressAnimationDuration = const Duration(milliseconds: 500);
  final Duration _releaseAnimationDuration = const Duration(milliseconds: 700);

  // Pulse animation controller
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  final double _pulseMinValue = 0.7;
  final double _pulseMaxValue = 1.0;
  final Duration _pulseDuration = const Duration(milliseconds: 1500);

  // Progress bar animation controller
  late AnimationController _progressController;
  double _currentProgress = 0.0;

  // Variety value (0.0 ~ 1.0)
  double _variety = 0.5;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: _fixedAnimationValue,
    );

    // Set up animation
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Add animation listener
    _animation.addListener(() {
      if (mounted) {
        // Use WidgetsBinding.instance.addPostFrameCallback to avoid setState calls during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _animationValue = _animation.value;
            });
          }
        });
      }
    });

    // Initialize pulse animation controller
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: _pulseDuration,
    );

    // Set up pulse animation
    _pulseAnimation = Tween<double>(
      begin: _pulseMinValue,
      end: _pulseMaxValue,
    ).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Add pulse animation listener
    _pulseAnimation.addListener(() {
      if (mounted && _isPressed) {
        // Use WidgetsBinding.instance.addPostFrameCallback to avoid setState calls during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isPressed) {
            setState(() {
              // Apply animation value only when pressed
              _animationValue = _pulseAnimation.value;
            });
          }
        });
      }
    });

    // Add status listener to reverse the animation when it completes
    _pulseAnimationController.addStatusListener((status) {
      if (!mounted) return;

      // Use WidgetsBinding.instance.addPostFrameCallback to avoid setState calls during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (status == AnimationStatus.completed) {
          _pulseAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          if (_isPressed) {
            // Restart if still pressed
            _pulseAnimationController.forward();
          }
        }
      });
    });

    // Animation controller status listener
    _animationController.addStatusListener((status) {
      if (!mounted) return;

      // Use WidgetsBinding.instance.addPostFrameCallback to avoid setState calls during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          setState(() {
            _isAnimating = false;
          });
        } else {
          if (!_isAnimating) {
            setState(() {
              _isAnimating = true;
            });
          }
        }
      });
    });

    // Progress bar animation controller initialization
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Assuming 30-minute song
    );

    _progressController.addListener(() {
      // Use WidgetsBinding.instance.addPostFrameCallback to avoid setState calls during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentProgress = _progressController.value;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _changeAlbum(bool next) {
    setState(() {
      if (next) {
        _currentAlbumIndex = (_currentAlbumIndex + 1) % _albums.length;
      } else {
        _currentAlbumIndex =
            (_currentAlbumIndex - 1 + _albums.length) % _albums.length;
      }
      _currentPalette = null; // Reset palette when changing image

      // Reset progress when switching album
      _progressController.reset();
      if (_isPlaying) {
        _progressController.forward();
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;

      if (_isPlaying) {
        _progressController.forward();
      } else {
        _progressController.stop();
      }
    });
  }

  void _updatePalette(AuraColorPalette palette) {
    // Use WidgetsBinding.instance.addPostFrameCallback to avoid setState calls during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentPalette = palette;
        });

        // Log color information
        debugPrint('✅ Color palette updated:');
        debugPrint(
            '  - Primary: RGB(${palette.primary.red}, ${palette.primary.green}, ${palette.primary.blue})');
        debugPrint(
            '  - Secondary: RGB(${palette.secondary.red}, ${palette.secondary.green}, ${palette.secondary.blue})');
        debugPrint(
            '  - Tertiary: RGB(${palette.tertiary.red}, ${palette.tertiary.green}, ${palette.tertiary.blue})');
        debugPrint(
            '  - Light: RGB(${palette.light.red}, ${palette.light.green}, ${palette.light.blue})');
        debugPrint(
            '  - Dark: RGB(${palette.dark.red}, ${palette.dark.green}, ${palette.dark.blue})');
      }
    });
  }

  // Show control panel as bottom sheet
  void _showControlPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ControlPanel(
          animationValue: _animationValue,
          auraStyle: _auraStyle,
          useCustomBlur: _useCustomBlur,
          blurStrength: _blurStrength,
          blurStrengthX: _useCustomBlur ? _blurStrengthX : null,
          blurStrengthY: _useCustomBlur ? _blurStrengthY : null,
          blurLayerOpacity: _blurLayerOpacity,
          variety: _variety,
          currentPalette: _currentPalette,
          onAnimationValueChanged: (value) {
            setState(() {
              _animationValue = value;
            });
          },
          onAuraStyleChanged: (value) {
            setState(() {
              _auraStyle = value;
            });
          },
          onUseCustomBlurChanged: (value) {
            setState(() {
              _useCustomBlur = value;
            });
          },
          onBlurStrengthChanged: (value) {
            setState(() {
              _blurStrength = value;
            });
          },
          onBlurStrengthXChanged: (value) {
            setState(() {
              _blurStrengthX = value;
            });
          },
          onBlurStrengthYChanged: (value) {
            setState(() {
              _blurStrengthY = value;
            });
          },
          onBlurLayerOpacityChanged: (value) {
            setState(() {
              _blurLayerOpacity = value;
            });
          },
          onVarietyChanged: (value) {
            setState(() {
              _variety = value;
            });
          },
        );
      },
    );
  }

  // Toggle animation function
  void _toggleAnimation() {
    if (_animationController.value > _minAnimationValue) {
      _animateToValue(_minAnimationValue, _releaseAnimationDuration);
    } else {
      _animateToValue(_maxAnimationValue, _pressAnimationDuration);
    }
  }

  // Gesture handler - touch start
  void _handleTouchDown() {
    if (_isPressed) return; // If already pressed, ignore

    // Save current animation value
    final currentValue = _animationValue;

    // Stop all animations before changing value
    _animationController.stop();
    _pulseAnimationController.stop();

    // Update state at once
    setState(() {
      _isPressed = true;
      // If current value is already close to target value, keep it, otherwise set to start value
      if ((currentValue - _pulseMinValue).abs() > 0.1) {
        _animationValue = _pulseMinValue;
      }
    });

    // Start pulse animation immediately (without delay)
    _pulseAnimationController.value = 0.0;
    _pulseAnimationController.forward();
  }

  // Gesture handler - touch end
  void _handleTouchUp() {
    if (!_isPressed) return; // If already released, ignore

    // Save current animation value
    final double currentValue = _animationValue;

    // Stop pulse animation
    _pulseAnimationController.stop();

    // Update state at once
    setState(() {
      _isPressed = false;
    });

    // Reset animation controller (starting from current value)
    _animationController.value = currentValue;

    // Start animation immediately (without delay)
    _animateToValue(_fixedAnimationValue, _releaseAnimationDuration);
  }

  // Gesture handler - touch cancel
  void _handleTouchCancel() {
    if (!_isPressed) return; // If already canceled, ignore

    // Save current animation value
    final double currentValue = _animationValue;

    // Stop pulse animation
    _pulseAnimationController.stop();

    // Update state at once
    setState(() {
      _isPressed = false;
    });

    // Reset animation controller (starting from current value)
    _animationController.value = currentValue;

    // Start animation immediately (without delay)
    _animateToValue(_fixedAnimationValue, _releaseAnimationDuration);
  }

  // Animate to specific value
  void _animateToValue(double targetValue, Duration duration) {
    if (!mounted) return;

    // If already close to target value, skip animation
    if ((targetValue - _animationValue).abs() < 0.01) {
      setState(() {
        _animationValue = targetValue;
      });
      return;
    }

    _animationController.duration = duration;
    _animationController.animateTo(
      targetValue,
      curve: Curves.easeInOutCubic,
    );
  }

  // Calculate album cover scale based on animation value (100~110%)
  double _calculateAlbumScale() {
    // If pressed, use fixed size
    if (_isPressed) {
      return 1.08; // Fixed maximum size
    }

    // If not animating and close to fixed value, return exact value
    if (!_isAnimating &&
        (_animationValue - _fixedAnimationValue).abs() < 0.01) {
      return 1.0 +
          (0.08 *
              (_fixedAnimationValue - _minAnimationValue) /
              (_maxAnimationValue - _minAnimationValue));
    }

    // If animation value is out of range, limit it
    double safeAnimationValue = _animationValue;
    if (safeAnimationValue < _minAnimationValue)
      safeAnimationValue = _minAnimationValue;
    if (safeAnimationValue > _maxAnimationValue)
      safeAnimationValue = _maxAnimationValue;

    // For other cases, calculate size based on animation value
    // 1.0 at _minAnimationValue, 1.08 at _maxAnimationValue
    return 1.0 +
        (0.08 *
            (safeAnimationValue - _minAnimationValue) /
            (_maxAnimationValue - _minAnimationValue));
  }

  @override
  Widget build(BuildContext context) {
    final currentAlbum = _albums[_currentAlbumIndex];
    final textColor = Colors.white;
    final iconColor = Colors.white;

    return Scaffold(
      body: AdaptiveAuraContainer(
        image: currentAlbum.image,
        onPaletteGenerated: _updatePalette,
        // Set color transition animation duration
        colorTransitionDuration: const Duration(milliseconds: 400),
        // Blur settings
        blurStrength: _useCustomBlur ? null : _blurStrength,
        blurStrengthX: _useCustomBlur ? _blurStrengthX : null,
        blurStrengthY: _useCustomBlur ? _blurStrengthY : null,
        blurLayerOpacity: _blurLayerOpacity,
        // Aura style
        auraStyle: _auraStyle,
        // Animation value
        animationValue: _animationValue,
        animationDuration: const Duration(milliseconds: 200),
        variety: _variety,
        child: SafeArea(
          child: Column(
            children: [
              // Top app bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
                      onPressed: () {
                        // Minimize app (show control panel in this example)
                        _showControlPanel();
                      },
                    ),
                    Text(
                      'Now Playing',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: iconColor),
                      onPressed: () {
                        // More options (show control panel in this example)
                        _showControlPanel();
                      },
                    ),
                  ],
                ),
              ),

              // Album cover (centered)
              Expanded(
                flex: 5, // Album cover area ratio
                child: Center(
                  child: GestureDetector(
                    onTapDown: (_) => _handleTouchDown(),
                    onTapUp: (_) => _handleTouchUp(),
                    onTapCancel: () => _handleTouchCancel(),
                    onLongPressStart: (_) => _handleTouchDown(),
                    onLongPressEnd: (_) => _handleTouchUp(),
                    child: RepaintBoundary(
                      child: AnimatedScale(
                        scale: _calculateAlbumScale(),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image(
                            image: currentAlbum.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom control area
              Expanded(
                flex: 3, // Adjust ratio of control area
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Changed to top alignment
                    children: [
                      // Album information
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          currentAlbum.title,
                          key: ValueKey<String>(currentAlbum.title),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          currentAlbum.artist,
                          key: ValueKey<String>(currentAlbum.artist),
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Progress bar
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          activeTrackColor: textColor,
                          inactiveTrackColor: textColor.withOpacity(0.3),
                          thumbColor: textColor,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 16),
                        ),
                        child: Slider(
                          value: _currentProgress,
                          onChanged: (value) {
                            setState(() {
                              _currentProgress = value;
                              _progressController.value = value;
                            });
                          },
                        ),
                      ),

                      // Time display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentProgress *
                                  30 *
                                  60), // Assuming 30-minute song
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(
                                  30 * 60), // Assuming 30-minute song
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Play control
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.shuffle,
                                color: iconColor.withOpacity(0.8)),
                            onPressed: () {},
                            iconSize: 28,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: iconColor),
                            onPressed: () => _changeAlbum(false),
                            iconSize: 36,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: textColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                              ),
                              onPressed: _togglePlayPause,
                              iconSize: 36,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: iconColor),
                            onPressed: () => _changeAlbum(true),
                            iconSize: 36,
                          ),
                          IconButton(
                            icon: Icon(Icons.repeat,
                                color: iconColor.withOpacity(0.8)),
                            onPressed: () {},
                            iconSize: 28,
                          ),
                        ],
                      ),
                      // Add margin for floating button
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Control panel button
            FloatingActionButton(
              onPressed: _showControlPanel,
              tooltip: 'Control Panel',
              heroTag: 'controlPanel',
              backgroundColor: Colors.white,
              child: const Icon(Icons.settings, color: Colors.black),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Time format function (seconds -> mm:ss)
  String _formatDuration(double seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds.toInt() % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
