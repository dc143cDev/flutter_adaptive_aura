import 'package:flutter/material.dart';
import 'screens/music_player_screen.dart';
import 'screens/car_select_screen.dart';
import 'screens/watch_showcase_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Aura Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Page controller
  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);

    // Show welcome dialog after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeGuide();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Show welcome guide dialog
  void _showWelcomeGuide() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WelcomeGuideDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: [
          MusicPlayerScreen(),
          WatchShowcaseScreen(),
          CarSelectScreen(),
        ],
      ),
      // Add a small guide button in the bottom left corner
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showWelcomeGuide,
        tooltip: 'Show Guide',
        backgroundColor: Colors.white.withOpacity(0.3),
        child: const Icon(Icons.help_outline, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class WelcomeGuideDialog extends StatefulWidget {
  @override
  _WelcomeGuideDialogState createState() => _WelcomeGuideDialogState();
}

class _WelcomeGuideDialogState extends State<WelcomeGuideDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  List<GuidePageData> _pages = [
    GuidePageData(
      title: "Welcome to Adaptive Aura Demo",
      description:
          "This app showcases the Adaptive Aura Flutter package, which creates dynamic lighting effects based on image colors and customizable parameters.",
      image: "assets/images/album_test01.webp",
      icon: Icons.music_note,
      pageDescription: "Music Player Demo",
      feature:
          "• Dynamic color extraction from images\n• Interactive animations with touch\n• Configurable visual effects",
    ),
    GuidePageData(
      title: "Explore Different Styles",
      description:
          "Swipe vertically to navigate between demo screens. Each screen demonstrates different applications of the Adaptive Aura container.",
      image: "assets/images/nomos_purple_draphed_01_2000x1335.png",
      icon: Icons.watch,
      pageDescription: "Watch Showcase Demo",
      feature:
          "• Color palette transition animations\n• Beautiful background effects\n• Product showcase with aura effects",
    ),
    GuidePageData(
      title: "Test Laboratory",
      description:
          "The Car Selection screen includes a test laboratory where you can experiment with different configurations and see how they affect the visual appearance.",
      image: "assets/images/mini_blue.webp",
      icon: Icons.science,
      pageDescription: "Car Selection Demo with Test Lab",
      feature:
          "• Test all combinations of images and palettes\n• Visualize different aura styles\n• Adjust blur, animation, and variety parameters",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header and close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Adaptive Aura Demo Guide",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // Page content
            Flexible(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    return _buildGuidePage(_pages[index]);
                  },
                ),
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (hidden on first page)
                  _currentPage > 0
                      ? TextButton.icon(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: Icon(Icons.arrow_back, color: Colors.white70),
                          label: Text(
                            "Back",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : SizedBox(width: 100), // Spacer to maintain layout

                  // Next/Done button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _totalPages - 1) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      _currentPage < _totalPages - 1
                          ? "Next"
                          : "Start Exploring",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidePage(GuidePageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Page icon and description
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(page.icon, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  page.pageDescription,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Title
          Text(
            page.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 24),

          // Image preview
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Image container with gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Image
                        Container(
                          width: double.infinity,
                          height: 200,
                          child: Image.asset(
                            page.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Control panel icon indicator
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Feature list
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Key Features:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  page.feature,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GuidePageData {
  final String title;
  final String description;
  final String image;
  final IconData icon;
  final String pageDescription;
  final String feature;

  GuidePageData({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.pageDescription,
    required this.feature,
  });
}
