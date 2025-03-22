import 'package:flutter/material.dart';
import 'package:adaptive_aura/adaptive_aura.dart';
import '../widgets/control_panel.dart';

class WatchShowcaseScreen extends StatefulWidget {
  const WatchShowcaseScreen({Key? key}) : super(key: key);

  @override
  State<WatchShowcaseScreen> createState() => _WatchShowcaseScreenState();
}

class _WatchShowcaseScreenState extends State<WatchShowcaseScreen>
    with TickerProviderStateMixin {
  // Selected watch index
  int _selectedWatchIndex = 0;
  // Color palette
  AuraColorPalette? _colorPalette;

  // Style and effect settings
  AuraStyle _auraStyle = AuraStyle.sunray; // Default to sunray style
  double _animationValue = 0.7;
  bool _useCustomBlur = false;
  double _blurStrength = 15.0;
  double _blurStrengthX = 15.0;
  double _blurStrengthY = 15.0;
  double _blurLayerOpacity = 0.1;
  double _variety = 0.3; // Initial value suitable for sunray style

  // Page controller
  late PageController _watchPageController;

  // Nomos watch image paths
  final List<String> _watchImages = [
    // 'assets/images/nomos_green_draphed_01_2000x1335.png',
    'assets/images/nomos_pink_draphed_01_2000x1334.png',
    'assets/images/nomos_purple_draphed_01_2000x1335.png',
    'assets/images/nomos_sky_blue_draphed_01_2000x1335.png',
    'assets/images/nomos_turquoise_draphed_01_2000x1335.png',
  ];

  // Watch model names
  final List<String> _watchNames = [
    //'Nomos Club Green',
    'Nomos Club',
    'Nomos Club Sport',
    'Nomos Ahoi',
    'Nomos Club Campus',
  ];

  // Watch collection descriptions
  final List<String> _watchDescriptions = [
    //'Nomos Club Green',
    'Pink',
    'Purple',
    'Sky Blue',
    'Turquoise',
  ];

  // Watch prices
  final List<String> _watchPrices = [
    //'₩2,450,000',
    '₩2,480,000',
    '₩2,390,000',
    '₩2,420,000',
    '₩2,490,000',
  ];

  late ImageProvider _currentWatchImageProvider;

  @override
  void initState() {
    super.initState();
    // Initialize page controller
    _watchPageController = PageController(initialPage: _selectedWatchIndex);
    // Set current image provider
    _updateCurrentImageProvider();
    // Initialize palette
    _updateColorPalette();
  }

  @override
  void dispose() {
    _watchPageController.dispose();
    super.dispose();
  }

  // Update current watch image provider
  void _updateCurrentImageProvider() {
    _currentWatchImageProvider = AssetImage(_watchImages[_selectedWatchIndex]);
  }

  // Generate palette from image
  void _updateColorPalette() async {
    try {
      // Extract palette from image
      final palette = await ColorExtractor.extractColorsFromImage(
        imageProvider: _currentWatchImageProvider,
        enableLogging: true,
      );

      setState(() {
        _colorPalette = palette;
      });
    } catch (e) {
      debugPrint('Failed to extract palette from image: $e');
      // Set default palette on failure
      setState(() {
        _colorPalette = AuraColorPalette.defaultPalette();
      });
    }
  }

  void _showControlPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => ControlPanel(
        animationValue: _animationValue,
        auraStyle: _auraStyle,
        useCustomBlur: _useCustomBlur,
        blurStrength: _blurStrength,
        blurStrengthX: _blurStrengthX,
        blurStrengthY: _blurStrengthY,
        blurLayerOpacity: _blurLayerOpacity,
        variety: _variety,
        currentPalette: _colorPalette,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true, // Extend body to bottom navigation area
      extendBodyBehindAppBar: true, // Extend body behind app bar
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: _showControlPanel,
        tooltip: 'Control Panel',
        backgroundColor: Colors.white,
        child: const Icon(Icons.settings, color: Colors.black),
      ),
      body: AdaptiveAuraContainer(
        image: _currentWatchImageProvider,
        //colorPalette: _colorPalette,
        onPaletteGenerated: (palette) {
          if (mounted) {
            setState(() {
              _colorPalette = palette;
            });
          }
        },
        animationValue: _animationValue,
        auraStyle: _auraStyle,
        blurStrength: _useCustomBlur ? null : _blurStrength,
        blurStrengthX: _useCustomBlur ? _blurStrengthX : null,
        blurStrengthY: _useCustomBlur ? _blurStrengthY : null,
        blurLayerOpacity: _blurLayerOpacity,
        variety: _variety,
        colorTransitionDuration: const Duration(milliseconds: 400),
        child: Stack(
          fit: StackFit.expand, // Make stack fill the entire screen
          children: [
            // Watch image layer (bottom-most layer, covers entire screen)
            Positioned.fill(
              child: PageView.builder(
                controller: _watchPageController,
                itemCount: _watchImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedWatchIndex = index;
                    _updateCurrentImageProvider();
                    _updateColorPalette();
                  });
                },
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      // Watch image - starts at bottom right and extends below navigation bar
                      Positioned(
                        bottom:
                            -50, // Extend beyond screen (below navigation bar)
                        right: -screenSize.width * 0.1,
                        width: screenSize.width * 1.3,
                        height: screenSize.height * 0.9,
                        child: Hero(
                          tag: 'watch_image_$index',
                          child: Image(
                            image: AssetImage(_watchImages[index]),
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // UI elements in safe area
            SafeArea(
              bottom:
                  false, // Ignore bottom safe area (UI extends to navigation bar)
              child: Stack(
                children: [
                  // Top-left content area
                  Positioned(
                    top: 16,
                    left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand name
                        const Text(
                          "NOMOS GLASHÜTTE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),

                        SizedBox(height: screenSize.height * 0.03),

                        // Model name
                        SizedBox(
                          width: screenSize.width * 0.6,
                          child: Text(
                            _watchNames[_selectedWatchIndex],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Collection name
                        Text(
                          _watchDescriptions[_selectedWatchIndex],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w300,
                          ),
                        ),

                        SizedBox(height: screenSize.height * 0.06),

                        // Price information
                        Text(
                          _watchPrices[_selectedWatchIndex],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Purchase button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _colorPalette?.primary.withOpacity(0.8) ??
                                    Colors.white,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Buy Now",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Page indicator positioned at bottom, above navigation bar
            Positioned(
              bottom: bottomPadding + 16, // Margin above navigation bar
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _watchImages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedWatchIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
