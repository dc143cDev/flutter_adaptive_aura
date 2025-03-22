part of '../adaptive_aura.dart';

/// Apple Music style adaptive container with responsive album cover effects
class AdaptiveAuraContainer extends StatefulWidget {
  /// Image (optional)
  final ImageProvider? image;

  /// Custom color palette (optional)
  final AuraColorPalette? colorPalette;

  /// Child widget
  final Widget child;

  /// Animation duration
  final Duration animationDuration;

  /// Color transition animation duration
  final Duration colorTransitionDuration;

  /// Blur strength (X-axis)
  final double? blurStrengthX;

  /// Blur strength (Y-axis)
  final double? blurStrengthY;

  /// Blur strength (applied equally to X and Y axes)
  final double? blurStrength;

  /// Blur layer opacity
  final double? blurLayerOpacity;

  /// Color intensity
  final double colorIntensity;

  /// Aura effect style
  final AuraStyle auraStyle;

  /// Callback when color palette is generated
  final void Function(AuraColorPalette)? onPaletteGenerated;

  /// Enable debug logging
  final bool enableLogging;

  /// Animation value (0.0 ~ 1.0)
  final double animationValue;

  /// Container width (if null, fits to parent widget)
  final double? width;

  /// Container height (if null, fits to parent widget)
  final double? height;

  /// Variety value (0.0 ~ 1.0)
  /// Higher values generate more elements and complex effects
  final double variety;

  /// Constructor for Apple Music style adaptive aura container
  const AdaptiveAuraContainer({
    super.key,
    this.image,
    this.colorPalette,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 800),
    this.colorTransitionDuration = const Duration(milliseconds: 0),
    this.blurStrength = 20.0,
    this.blurStrengthX,
    this.blurStrengthY,
    this.blurLayerOpacity = 0.1,
    this.colorIntensity = 0.7,
    this.auraStyle = AuraStyle.blob,
    this.onPaletteGenerated,
    this.enableLogging = true,
    this.animationValue = 0.0,
    this.width,
    this.height,
    this.variety = 0.5,
  });

  @override
  State<AdaptiveAuraContainer> createState() => _AdaptiveAuraContainerState();
}

class _AdaptiveAuraContainerState extends State<AdaptiveAuraContainer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _colorTransitionController;
  late Animation<double> _colorTransitionAnimation;

  AuraColorPalette? _colorPalette;
  AuraColorPalette? _previousColorPalette;
  AuraColorPalette? _currentColorPalette;

  ImageProvider? _lastProcessedImage;
  Size _containerSize = Size.zero;
  bool _isTransitioning = false;
  bool _isUsingCustomPalette = false;

  /// Calculate effective blur strength for X-axis
  double get _effectiveBlurStrengthX =>
      widget.blurStrengthX ?? widget.blurStrength ?? 20.0;

  /// Calculate effective blur strength for Y-axis
  double get _effectiveBlurStrengthY =>
      widget.blurStrengthY ?? widget.blurStrength ?? 20.0;

  /// Calculate effective blur layer opacity
  double get _effectiveBlurLayerOpacity => widget.blurLayerOpacity ?? 0.1;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animationController.repeat(reverse: true);

    // Initialize color transition animation controller
    _colorTransitionController = AnimationController(
      vsync: this,
      duration: widget.colorTransitionDuration,
    );

    _colorTransitionAnimation = CurvedAnimation(
      parent: _colorTransitionController,
      curve: Curves.easeInOut,
    );

    _colorTransitionAnimation.addListener(() {
      if (mounted) {
        setState(() {
          // Update current color palette whenever animation value changes
          if (_previousColorPalette != null && _colorPalette != null) {
            _currentColorPalette = _lerpColorPalette(
              _previousColorPalette!,
              _colorPalette!,
              _colorTransitionAnimation.value,
            );
          }
        });
      }
    });

    _colorTransitionAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isTransitioning = false;
          _previousColorPalette = null;
        });
      }
    });

    // Setup initial color palette
    _setupInitialColorPalette();
  }

  /// Create default palette when no image or custom palette is provided
  AuraColorPalette _createDefaultPalette() {
    // Use a more interesting default palette based on system time
    // This way, each time the widget is created, it will have a slightly different look
    final now = DateTime.now();
    final seed =
        now.millisecondsSinceEpoch % 5; // 0-4 different default palettes

    switch (seed) {
      case 0: // Grayscale
        return const AuraColorPalette(
          primary: Color(0xFF757575),
          secondary: Color(0xFF9E9E9E),
          tertiary: Color(0xFF616161),
          light: Color(0xFFE0E0E0),
          dark: Color(0xFF212121),
        );
      case 1: // Cool blue
        return const AuraColorPalette(
          primary: Color(0xFF2196F3),
          secondary: Color(0xFF64B5F6),
          tertiary: Color(0xFF1976D2),
          light: Color(0xFFBBDEFB),
          dark: Color(0xFF0D47A1),
        );
      case 2: // Warm orange
        return const AuraColorPalette(
          primary: Color(0xFFFF9800),
          secondary: Color(0xFFFFB74D),
          tertiary: Color(0xFFF57C00),
          light: Color(0xFFFFE0B2),
          dark: Color(0xFFE65100),
        );
      case 3: // Nature green
        return const AuraColorPalette(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF81C784),
          tertiary: Color(0xFF388E3C),
          light: Color(0xFFC8E6C9),
          dark: Color(0xFF1B5E20),
        );
      case 4: // Vibrant purple
        return const AuraColorPalette(
          primary: Color(0xFF9C27B0),
          secondary: Color(0xFFBA68C8),
          tertiary: Color(0xFF7B1FA2),
          light: Color(0xFFE1BEE7),
          dark: Color(0xFF4A148C),
        );
      default: // Fallback to grayscale
        return const AuraColorPalette(
          primary: Color(0xFF757575),
          secondary: Color(0xFF9E9E9E),
          tertiary: Color(0xFF616161),
          light: Color(0xFFE0E0E0),
          dark: Color(0xFF212121),
        );
    }
  }

  /// Setup initial color palette
  void _setupInitialColorPalette() {
    // If custom palette is provided
    if (widget.colorPalette != null) {
      _isUsingCustomPalette = true;
      _colorPalette = widget.colorPalette;
      _currentColorPalette = widget.colorPalette;

      // Call callback
      if (widget.onPaletteGenerated != null) {
        widget.onPaletteGenerated!(_colorPalette!);
      }

      if (widget.enableLogging) {
        if (widget.image != null) {
          debugPrint('ℹ️ Using custom palette (ignoring image).');
        } else {
          debugPrint('ℹ️ Using custom palette (no image provided).');
        }
      }
    }
    // If image is provided
    else if (widget.image != null) {
      _generateColorPalette();
    }
    // If neither image nor custom palette is provided
    else {
      // Create default palette
      final defaultPalette = _createDefaultPalette();
      _colorPalette = defaultPalette;
      _currentColorPalette = defaultPalette;

      // Call callback
      if (widget.onPaletteGenerated != null) {
        widget.onPaletteGenerated!(defaultPalette);
      }

      if (widget.enableLogging) {
        debugPrint(
            'ℹ️ No image or custom palette provided, using default palette.');
      }
    }
  }

  /// Create grayscale palette
  AuraColorPalette _createGrayPalette() {
    return const AuraColorPalette(
      primary: Color(0xFF757575), // Medium gray
      secondary: Color(0xFF9E9E9E), // Light gray
      tertiary: Color(0xFF616161), // Dark gray
      light: Color(0xFFE0E0E0), // Very light gray
      dark: Color(0xFF212121), // Very dark gray
    );
  }

  @override
  void didUpdateWidget(AdaptiveAuraContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if custom palette has changed
    final hasCustomPaletteChanged =
        widget.colorPalette != oldWidget.colorPalette;

    // Check if image has changed
    final hasImageChanged = widget.image != oldWidget.image;

    // Check if custom palette usage status has changed
    final customPaletteStatusChanged =
        (widget.colorPalette != null && oldWidget.colorPalette == null) ||
            (widget.colorPalette == null && oldWidget.colorPalette != null);

    // Both image and custom palette are removed
    if (widget.image == null &&
        widget.colorPalette == null &&
        (oldWidget.image != null || oldWidget.colorPalette != null)) {
      if (widget.enableLogging) {
        debugPrint(
            'ℹ️ Both image and custom palette removed, using default palette.');
      }

      // Save current color palette as previous
      if (_colorPalette != null) {
        _previousColorPalette = _colorPalette;
        _isTransitioning = true;
      }

      // Set default palette
      final defaultPalette = _createDefaultPalette();
      setState(() {
        _isUsingCustomPalette = false;
        _colorPalette = defaultPalette;

        // If no previous palette, set current palette directly
        if (_previousColorPalette == null) {
          _currentColorPalette = defaultPalette;
        } else {
          // Start color transition animation
          _colorTransitionController.reset();
          _colorTransitionController.forward();
        }
      });

      // Call callback
      if (widget.onPaletteGenerated != null) {
        widget.onPaletteGenerated!(defaultPalette);
      }
    }
    // If custom palette has changed
    else if (hasCustomPaletteChanged && widget.colorPalette != null) {
      if (widget.enableLogging) {
        if (widget.image != null) {
          debugPrint('🔄 Using custom palette (ignoring image).');
        } else {
          debugPrint('🔄 Using custom palette (no image provided).');
        }
      }

      // Save current color palette as previous
      if (_colorPalette != null) {
        _previousColorPalette = _colorPalette;
        _isTransitioning = true;
      }

      setState(() {
        _isUsingCustomPalette = true;
        _colorPalette = widget.colorPalette;

        // If no previous palette, set current palette directly
        if (_previousColorPalette == null) {
          _currentColorPalette = widget.colorPalette;
        } else {
          // Start color transition animation
          _colorTransitionController.reset();
          _colorTransitionController.forward();
        }
      });

      // Call callback
      if (widget.onPaletteGenerated != null) {
        widget.onPaletteGenerated!(widget.colorPalette!);
      }
    }
    // If custom palette is removed and image is provided
    else if (customPaletteStatusChanged &&
        widget.colorPalette == null &&
        widget.image != null) {
      if (widget.enableLogging) {
        debugPrint('🔄 Custom palette removed, extracting colors from image.');
      }

      setState(() {
        _isUsingCustomPalette = false;
      });

      // Save current color palette as previous
      if (_colorPalette != null) {
        _previousColorPalette = _colorPalette;
        _isTransitioning = true;
      }

      _generateColorPalette();
    }
    // If image has changed and not using custom palette
    else if (hasImageChanged && !_isUsingCustomPalette) {
      if (widget.enableLogging) {
        debugPrint('🔄 Image changed, regenerating color palette.');
      }

      // If image is removed
      if (widget.image == null) {
        if (widget.enableLogging) {
          debugPrint('ℹ️ Image removed, using grayscale palette.');
        }

        // Save current color palette as previous
        if (_colorPalette != null) {
          _previousColorPalette = _colorPalette;
          _isTransitioning = true;
        }

        // Set grayscale palette
        final grayPalette = _createGrayPalette();
        setState(() {
          _colorPalette = grayPalette;

          // If no previous palette, set current palette directly
          if (_previousColorPalette == null) {
            _currentColorPalette = grayPalette;
          } else {
            // Start color transition animation
            _colorTransitionController.reset();
            _colorTransitionController.forward();
          }
        });

        // Call callback
        if (widget.onPaletteGenerated != null) {
          widget.onPaletteGenerated!(grayPalette);
        }
      }
      // If new image is provided
      else {
        // Save current color palette as previous
        if (_colorPalette != null) {
          _previousColorPalette = _colorPalette;
          _isTransitioning = true;
        }

        _generateColorPalette();
      }
    }

    // Update animation duration if changed
    if (widget.colorTransitionDuration != oldWidget.colorTransitionDuration) {
      _colorTransitionController.duration = widget.colorTransitionDuration;
    }
  }

  /// Interpolate between two color palettes
  AuraColorPalette _lerpColorPalette(
    AuraColorPalette from,
    AuraColorPalette to,
    double t,
  ) {
    return AuraColorPalette(
      primary: Color.lerp(from.primary, to.primary, t)!,
      secondary: Color.lerp(from.secondary, to.secondary, t)!,
      tertiary: Color.lerp(from.tertiary, to.tertiary, t)!,
      light: Color.lerp(from.light, to.light, t)!,
      dark: Color.lerp(from.dark, to.dark, t)!,
    );
  }

  Future<void> _generateColorPalette() async {
    // Skip if using custom palette or no image
    if (_isUsingCustomPalette || widget.image == null) {
      return;
    }

    try {
      if (_lastProcessedImage == widget.image && !_isTransitioning) {
        if (widget.enableLogging) {
          debugPrint('⏩ Image already processed, skipping palette generation.');
        }
        return;
      }

      _lastProcessedImage = widget.image;

      final palette = await ColorExtractor.extractColorsFromImage(
        imageProvider: widget.image!,
        enableLogging: widget.enableLogging,
      );

      if (mounted) {
        setState(() {
          _colorPalette = palette;

          // Set current palette directly if no previous palette
          if (_previousColorPalette == null) {
            _currentColorPalette = palette;
          } else {
            // Start color transition animation
            _colorTransitionController.reset();
            _colorTransitionController.forward();
          }
        });

        // Call callback
        widget.onPaletteGenerated?.call(palette);
      }
    } catch (e) {
      debugPrint('❌ Error generating color palette: $e');
      if (mounted) {
        // Use grayscale palette
        final grayPalette = _createGrayPalette();
        setState(() {
          _colorPalette = grayPalette;
          _currentColorPalette = grayPalette;
        });

        // Call callback
        widget.onPaletteGenerated?.call(grayPalette);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _colorTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentColorPalette == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Use specified size if provided, otherwise use LayoutBuilder
    if (widget.width != null && widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: _buildContent(Size(widget.width!, widget.height!)),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Check if container has valid size
      final hasValidSize =
          constraints.maxWidth > 0 && constraints.maxHeight > 0;

      if (!hasValidSize) {
        // Set minimum size if invalid
        return Container(
          width: 100,
          height: 100,
          color: Colors.black,
          child: const Center(
            child: Text(
              "Invalid size",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }

      // Save container size
      _containerSize = Size(
        widget.width ?? constraints.maxWidth,
        widget.height ?? constraints.maxHeight,
      );

      return _buildContent(_containerSize);
    });
  }

  /// Build container content
  Widget _buildContent(Size size) {
    // Create layer based on selected style
    final styleLayer = _createStyleLayer(size);

    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.zero,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            // Build style layer
            styleLayer,

            // Child widget
            widget.child,
          ],
        ),
      ),
    );
  }

  /// Create aura style layer
  AuraStyleLayer _createStyleLayer(Size containerSize) {
    return AuraStyleLayer.create(
      style: widget.auraStyle,
      colorPalette: _currentColorPalette!,
      animationController: _animationController,
      animationDuration: widget.animationDuration,
      blurStrengthX: _effectiveBlurStrengthX,
      blurStrengthY: _effectiveBlurStrengthY,
      blurLayerOpacity: _effectiveBlurLayerOpacity,
      colorIntensity: widget.colorIntensity,
      animationValue: widget.animationValue,
      containerSize: containerSize,
      variety: widget.variety,
    );
  }
}
