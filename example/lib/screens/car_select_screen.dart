import 'package:flutter/material.dart';
import 'package:adaptive_aura/adaptive_aura.dart';
import '../widgets/control_panel.dart';

class CarSelectScreen extends StatefulWidget {
  const CarSelectScreen({Key? key}) : super(key: key);

  @override
  State<CarSelectScreen> createState() => _CarSelectScreenState();
}

class _CarSelectScreenState extends State<CarSelectScreen>
    with TickerProviderStateMixin {
  // Selected car index
  int _selectedCarIndex = 0;
  // Color palette
  AuraColorPalette? _colorPalette;

  // Style and effect settings
  AuraStyle _auraStyle = AuraStyle.blob;
  double _animationValue = 0.7;
  bool _useCustomBlur = false;
  double _blurStrength = 20.0;
  double _blurStrengthX = 20.0;
  double _blurStrengthY = 20.0;
  double _blurLayerOpacity = 0.1;
  double _variety = 0.15;

  // Page controller
  late PageController _carPageController;

  // Mini Cooper image paths
  final List<String> _carImages = [
    'assets/images/mini_blue.webp',
    'assets/images/mini_brg.webp',
    'assets/images/mini_emerald_grey.webp',
    'assets/images/mini_moonwalk_gray.webp',
    'assets/images/mini_solaris_orange.webp',
    'assets/images/mini_zesty_yellow.webp',
  ];
  late ImageProvider _currentCarImageProvider;

  // Test mode variables
  bool _useCustomPalette = false;
  bool _useImage = true;

  // Custom color palettes for testing
  final List<AuraColorPalette> _customPalettes = [
    // Blue Mini - Custom blue theme
    AuraColorPalette(
      primary: Color(0xFF1565C0), // Deep blue
      secondary: Color(0xFF42A5F5), // Light blue
      tertiary: Color(0xFF0D47A1), // Navy blue
      light: Color(0xFFBBDEFB), // Very light blue
      dark: Color(0xFF0A2351), // Dark navy
    ),
    // British Racing Green - Custom green theme
    AuraColorPalette(
      primary: Color(0xFF2E7D32), // Forest green
      secondary: Color(0xFF66BB6A), // Light green
      tertiary: Color(0xFF1B5E20), // Dark green
      light: Color(0xFFC8E6C9), // Very light green
      dark: Color(0xFF0A2E0A), // Very dark green
    ),
    // Emerald Grey - Custom grey-green theme
    AuraColorPalette(
      primary: Color(0xFF546E7A), // Blue grey
      secondary: Color(0xFF78909C), // Light blue grey
      tertiary: Color(0xFF455A64), // Dark blue grey
      light: Color(0xFFCFD8DC), // Very light blue grey
      dark: Color(0xFF263238), // Very dark blue grey
    ),
    // Moonwalk Gray - Custom grey theme
    AuraColorPalette(
      primary: Color(0xFF757575), // Medium grey
      secondary: Color(0xFF9E9E9E), // Light grey
      tertiary: Color(0xFF616161), // Dark grey
      light: Color(0xFFE0E0E0), // Very light grey
      dark: Color(0xFF212121), // Very dark grey
    ),
    // Solaris Orange - Custom orange theme
    AuraColorPalette(
      primary: Color(0xFFE65100), // Deep orange
      secondary: Color(0xFFFF9800), // Orange
      tertiary: Color(0xFFEF6C00), // Dark orange
      light: Color(0xFFFFE0B2), // Very light orange
      dark: Color(0xFF8F3900), // Brown
    ),
    // Zesty Yellow - Custom yellow theme
    AuraColorPalette(
      primary: Color(0xFFFBC02D), // Yellow
      secondary: Color(0xFFFFEB3B), // Light yellow
      tertiary: Color(0xFFF9A825), // Dark yellow
      light: Color(0xFFFFF9C4), // Very light yellow
      dark: Color(0xFFF57F17), // Amber
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize page controller
    _carPageController = PageController(initialPage: _selectedCarIndex);
    // Set current image provider
    _updateCurrentImageProvider();
    // Initialize palette
    _updateColorPalette();
  }

  @override
  void dispose() {
    _carPageController.dispose();
    super.dispose();
  }

  // Update current car image provider
  void _updateCurrentImageProvider() {
    _currentCarImageProvider = AssetImage(_carImages[_selectedCarIndex]);
  }

  // Generate palette from image
  void _updateColorPalette() async {
    // Use custom palette if test mode is active
    if (_useCustomPalette) {
      setState(() {
        _colorPalette = _customPalettes[_selectedCarIndex];
      });
      return;
    }

    try {
      // Extract palette from image
      final palette = await ColorExtractor.extractColorsFromImage(
        imageProvider: _currentCarImageProvider,
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

  // Show test panel with various configuration options
  void _showTestPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Test Configuration",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              // Custom palette toggle
              SwitchListTile(
                title: Text(
                  "Use Custom Palette",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "When enabled, custom palettes will be used instead of extracting from images",
                  style: TextStyle(color: Colors.white70),
                ),
                value: _useCustomPalette,
                onChanged: (value) {
                  setState(() {
                    _useCustomPalette = value;
                  });

                  this.setState(() {
                    if (_useCustomPalette) {
                      _colorPalette = _customPalettes[_selectedCarIndex];
                    } else {
                      _updateColorPalette();
                    }
                  });
                },
                activeColor: Colors.blue,
              ),

              // Image toggle
              SwitchListTile(
                title: Text(
                  "Use Image",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "Toggle to test with/without image",
                  style: TextStyle(color: Colors.white70),
                ),
                value: _useImage,
                onChanged: (value) {
                  setState(() {
                    _useImage = value;
                  });

                  this.setState(() {});
                },
                activeColor: Colors.blue,
              ),

              // Current test scenario
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Test Scenario:",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Image: ${_useImage ? 'Yes' : 'No'}",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Custom Palette: ${_useCustomPalette ? 'Yes' : 'No'}",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _getScenarioDescription(),
                      style: TextStyle(
                        color: Colors.yellow,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Test buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      this.setState(() {
                        _updateColorPalette();
                      });
                    },
                    child: Text("Apply Changes"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Close"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white38),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get description for current test scenario
  String _getScenarioDescription() {
    if (_useImage && _useCustomPalette) {
      return "Scenario 1: Image + Custom Palette (custom palette should be used)";
    } else if (!_useImage && !_useCustomPalette) {
      return "Scenario 2: No Image + No Custom Palette (fallback to default)";
    } else if (!_useImage && _useCustomPalette) {
      return "Scenario 3: No Image + Custom Palette (custom palette should be used)";
    } else {
      return "Scenario 4: Image + No Custom Palette (extract from image)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AdaptiveAuraContainer(
        // Conditionally provide image based on test settings
        image: _useImage ? _currentCarImageProvider : null,
        // Provide custom palette if test mode is active
        colorPalette:
            _useCustomPalette ? _customPalettes[_selectedCarIndex] : null,
        onPaletteGenerated: (palette) {
          // Image palette is automatically generated when called
          if (mounted) {
            setState(() {
              // Only update our local palette if we're not using custom palettes
              if (!_useCustomPalette) {
                _colorPalette = palette;
              }
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
        colorTransitionDuration: Duration(milliseconds: 300),
        child: SafeArea(
          child: Column(
            children: [
              // Top header with test controls
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "MINI Cooper S",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _getScenarioDescription(),
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Test panel button
                        IconButton(
                          icon: Icon(Icons.science, color: Colors.white),
                          onPressed: _showTestPanel,
                          tooltip: "Test Panel",
                        ),
                        SizedBox(width: 8),
                        // Test mode indicator
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "TEST MODE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Car image display area (swipe applied)
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _carPageController,
                      itemCount: _carImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedCarIndex = index;
                          _updateCurrentImageProvider();

                          // Update palette according to test settings
                          if (_useCustomPalette) {
                            _colorPalette = _customPalettes[_selectedCarIndex];
                          } else {
                            _updateColorPalette();
                          }
                        });
                      },
                      itemBuilder: (context, index) {
                        return Center(
                          child: Hero(
                            tag: 'car_image_$index',
                            child: _useImage
                                ? Image(
                                    image: AssetImage(_carImages[index]),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    fit: BoxFit.contain,
                                  )
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Image Disabled",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    // Show overlay if test scenarios
                    if (!_useImage)
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Image Disabled for Testing",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Color information area
              if (_colorPalette != null)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Color Palette",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_useCustomPalette)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Custom",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (!_useImage && !_useCustomPalette)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Default",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildColorSwatch(
                                  'Primary', _colorPalette!.primary),
                              SizedBox(width: 12),
                              _buildColorSwatch(
                                  'Secondary', _colorPalette!.secondary),
                              SizedBox(width: 12),
                              _buildColorSwatch(
                                  'Tertiary', _colorPalette!.tertiary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom information area and page indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Page indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _carImages.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedCarIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Information text
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Test panel FAB
          FloatingActionButton(
            onPressed: _showTestPanel,
            tooltip: 'Test Panel',
            backgroundColor: Colors.red.withOpacity(0.7),
            heroTag: 'testPanel',
            child: const Icon(Icons.science, color: Colors.white),
          ),
          SizedBox(width: 16),
          // Control panel FAB
          FloatingActionButton(
            onPressed: _showControlPanel,
            tooltip: 'Control Panel',
            backgroundColor: Colors.white,
            heroTag: 'controlPanel',
            child: const Icon(Icons.settings, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // Color swatch widget creation
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
