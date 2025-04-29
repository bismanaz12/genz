import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gen_z/carorderscreen.dart';
import 'package:gen_z/chatscreen.dart';
import 'package:gen_z/notiifcation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

// API Service Class with improved logging
class ApiService {
  static const String baseUrl = 'http://178.128.150.238';

  // Helper method to ensure complete image URLs
  String ensureCompleteImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else {
      // If the image path is relative, prepend the base URL
      return '$baseUrl$imagePath';
    }
  }

// Fetch car specifications (speed, power, engine, etc.)
  // Modified fetchCarSpecs method with improved error handling and logging
  // Modified fetchCarSpecs method with proper null handling
  Future<Map<String, String>> fetchCarSpecs(String slug) async {
    try {
      print('Fetching specifications for car: $slug');

      // First try to get specs from features endpoint
      final featuresUri = Uri.parse('$baseUrl/auth/api/features/roller/$slug/');
      final featuresResponse = await http.get(featuresUri);

      print(
          'Features response status for $slug: ${featuresResponse.statusCode}');

      Map<String, String> specs = {
        'topSpeed': 'N/A',
        'maxPower': 'N/A',
        'engine': 'N/A',
        'acceleration': 'N/A',
      };

      if (featuresResponse.statusCode == 200) {
        final json = jsonDecode(featuresResponse.body);
        print(
            'Features response body: ${featuresResponse.body.substring(0, math.min(200, featuresResponse.body.length))}...');

        if (json['success'] == true && json['data'] != null) {
          final features = json['data'] as List<dynamic>;
          print('Found ${features.length} features for $slug');

          // Extract specs from features data
          for (var feature in features) {
            // Handle null safely
            String name = '';
            if (feature['name'] != null) {
              name = feature['name'].toString().toLowerCase();
            }

            String value = 'N/A';
            if (feature['value'] != null) {
              value = feature['value'].toString();
            } else if (feature['name'] != null) {
              value = feature['name'].toString();
            }

            if (name.contains('top speed') || name.contains('max speed')) {
              specs['topSpeed'] = value;
            } else if (name.contains('power') || name.contains('hp')) {
              specs['maxPower'] = value;
            } else if (name.contains('engine')) {
              specs['engine'] = value;
            } else if (name.contains('acceleration') || name.contains('0-60')) {
              specs['acceleration'] = value;
            }
          }

          print('Extracted specs for $slug: $specs');
        }
      }

      // If we couldn't get specs from features, try car details endpoint
      if (specs.values.every((value) => value == 'N/A')) {
        print(
            'No specs found from features endpoint, trying car details endpoint');
        final carDetailsUri = Uri.parse('$baseUrl/auth/api/car/$slug/');
        final carResponse = await http.get(carDetailsUri);

        if (carResponse.statusCode == 200) {
          final json = jsonDecode(carResponse.body);
          if (json['success'] == true && json['car'] != null) {
            final car = json['car'] as Map<String, dynamic>;

            // Try to extract specs from car details
            if (car['specifications'] != null) {
              final specifications =
                  car['specifications'] as Map<String, dynamic>;

              // Safely extract values with null handling
              if (specifications['top_speed'] != null) {
                specs['topSpeed'] = specifications['top_speed'].toString();
              }
              if (specifications['power'] != null) {
                specs['maxPower'] = specifications['power'].toString();
              }
              if (specifications['engine'] != null) {
                specs['engine'] = specifications['engine'].toString();
              }
              if (specifications['acceleration'] != null) {
                specs['acceleration'] =
                    specifications['acceleration'].toString();
              }
            }
          }
        }
      }

      // If still no specs, use fallback values based on the car slug
      if (specs.values.every((value) => value == 'N/A')) {
        print('Using fallback specs for $slug');
        if (slug == 'Mark-I') {
          specs = {
            'topSpeed': '180 mph',
            'maxPower': '450 HP',
            'engine': 'V8 Supercharged',
            'acceleration': '3.5s',
          };
        } else if (slug == 'Mark-II') {
          specs = {
            'topSpeed': '200 mph',
            'maxPower': '520 HP',
            'engine': 'V10 Turbo',
            'acceleration': '3.0s',
          };
        } else if (slug == 'Mark-IV') {
          specs = {
            'topSpeed': '220 mph',
            'maxPower': '600 HP',
            'engine': 'V12 Twin Turbo',
            'acceleration': '2.7s',
          };
        } else {
          // Generic fallback for any other car
          specs = {
            'topSpeed': '190 mph',
            'maxPower': '500 HP',
            'engine': 'V8 Engine',
            'acceleration': '3.2s',
          };
        }
      }

      return specs;
    } catch (e) {
      print('Error fetching specs for car $slug: $e');
      // Return fallback values on error
      return {
        'topSpeed': '190 mph',
        'maxPower': '500 HP',
        'engine': 'V8 Engine',
        'acceleration': '3.2s',
      };
    }
  }

  // Fetch landing images with detailed logging
  Future<List<dynamic>> fetchLandingImages() async {
    try {
      print('Fetching landing images from: $baseUrl/auth/api/landing-images/');
      final response =
          await http.get(Uri.parse('$baseUrl/auth/api/landing-images/'));

      print('Landing images response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print(
            'Landing images API response: ${json.toString().substring(0, math.min(500, json.toString().length))}...');

        if (json['success'] == true) {
          final data = json['data'] as List<dynamic>;
          print('Successfully fetched ${data.length} landing images');

          // Process each image URL to ensure it's complete
          for (var item in data) {
            if (item['web_image'] != null) {
              item['web_image'] =
                  ensureCompleteImageUrl(item['web_image'] as String);
              print('Processed image URL: ${item['web_image']}');
            }
          }

          return data;
        }
        print('API returned success: false for landing images');
        throw Exception('API returned success: false');
      }
      print(
          'Failed to load landing images: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load landing images: ${response.statusCode}');
    } catch (e) {
      print('Error fetching landing images: $e');
      rethrow;
    }
  }

  // Fetch car details by slug with detailed logging
  // Fetch car details by slug with detailed logging
  Future<Map<String, dynamic>?> fetchCarDetails(String slug) async {
    try {
      print(
          'Fetching car details for slug: $slug from $baseUrl/auth/api/car/$slug/');
      final response =
          await http.get(Uri.parse('$baseUrl/auth/api/car/$slug/'));

      print('Car details response status for $slug: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print(
            'Car details API response for $slug: ${json.toString().substring(0, math.min(500, json.toString().length))}...');

        if (json['success'] == true) {
          final car = json['car'] as Map<String, dynamic>;

          // Process image URLs in car details
          if (car['image'] != null) {
            car['image'] = ensureCompleteImageUrl(car['image'] as String);
            print('Processed car image URL for $slug: ${car['image']}');
          }

          return car;
        }
        print('API returned success: false for car details with slug $slug');
        return null;
      }
      print(
          'Failed to load car details for $slug: ${response.statusCode}, Body: ${response.body}');
      return null;
    } catch (e) {
      print('Error fetching car details for $slug: $e');
      return null;
    }
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> landingImages = [];
  List<Map<String, dynamic>> carModels = [];
  bool isLoading = true;
  String? errorMessage;
  int _currentBannerIndex = 0;

  // Fallback gradient colors
  final List<List<Color>> gradientColors = [
    [const Color(0xFF3A1C71), const Color(0xFFD76D77)],
    [const Color(0xFF000046), const Color(0xFF1CB5E0)],
    [const Color(0xFFE53935), const Color(0xFF8E24AA)],
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('Starting data fetch process...');

      // Fetch landing images for the banner
      try {
        final images = await _apiService.fetchLandingImages();
        print('Successfully retrieved ${images.length} landing images');

        // First, create landing images with placeholder values for specs
        landingImages = images
            .take(3)
            .map((item) => {
                  'image': item['web_image'] as String,
                  'title': item['title'] as String,
                  'description': item['subtitle'] as String,
                  'topSpeed': 'N/A', // Will be updated with car data
                  'maxPower': 'N/A', // Will be updated with car data
                  'engine': 'N/A', // Will be updated with car data
                  'acceleration': 'N/A', // Will be updated with car data
                  'gradientColors': gradientColors[
                      images.indexOf(item) % gradientColors.length],
                })
            .toList();

        print('Processed landing images: ${landingImages.length}');
      } catch (e) {
        print('Landing images fetch failed with error: $e');
        landingImages = [];
      }

      // Fetch car details for MARK I, MARK II, MARK IV
      const carSlugs = ['Mark-I', 'Mark-II', 'Mark-IV'];
      carModels = [];
      List<Map<String, String>> allCarSpecs = [];

      print('Fetching car models for slugs: $carSlugs');

      // Get car details and specs for all cars first
      for (int i = 0; i < carSlugs.length; i++) {
        final slug = carSlugs[i];
        try {
          print('Fetching car details for slug: $slug');
          final car = await _apiService.fetchCarDetails(slug);
          final specs = await _apiService.fetchCarSpecs(slug);
          allCarSpecs.add(specs); // Store specs for later use

          if (car != null) {
            print('Successfully retrieved car data for $slug');

            // Calculate which landing image to use (with proper boundary checking)
            final imageIndex = i % math.max(1, landingImages.length).toInt();

            // Safe handling of possible null values
            String imageUrl = 'assets/images/car.png'; // Default fallback
            if (car['image'] != null) {
              imageUrl = car['image'] as String;
            } else if (landingImages.isNotEmpty &&
                imageIndex < landingImages.length) {
              imageUrl = landingImages[imageIndex]['image'] as String;
            }

            // Safe handling of possible null title
            String carTitle = 'Car Model';
            if (car['title'] != null) {
              carTitle = car['title'] as String;
            }

            // Safe handling of possible null content
            String carDescription = 'No description available';
            if (car['content'] != null) {
              carDescription = car['content'] as String;
            }

            // Determine landing title with null safety
            String landingTitle = carTitle;
            if (landingImages.isNotEmpty && imageIndex < landingImages.length) {
              landingTitle = landingImages[imageIndex]['title'] as String;
            }

            // Create car model entry
            carModels.add({
              'image': imageUrl,
              'name': carTitle,
              'landingTitle': landingTitle,
              'description': carDescription,
              'gradientColors': gradientColors[i % gradientColors.length],
              // Add specs directly to car model (specs map is already non-nullable)
              'topSpeed': specs['topSpeed']!,
              'maxPower': specs['maxPower']!,
              'engine': specs['engine']!,
              'acceleration': specs['acceleration']!,

            });

            print('Added car model: $carTitle with specs: ${specs.toString()}');
          } else {
            print('Failed to fetch car model for slug $slug');
          }
        } catch (e) {
          print('Error processing car data for slug $slug: $e');
        }
      }

      // Now update the landing images with car specs
      // Make sure each landing image has specs, even if we have more or fewer landing images than cars
      for (int i = 0; i < landingImages.length; i++) {
        if (allCarSpecs.isEmpty) break; // Safety check

        final specIndex =
            i % allCarSpecs.length; // Cycle through available specs if needed
        Map<String, String> currentSpecs = allCarSpecs[specIndex];

        landingImages[i]['topSpeed'] = currentSpecs['topSpeed']!;
        landingImages[i]['maxPower'] = currentSpecs['maxPower']!;
        landingImages[i]['engine'] = currentSpecs['engine']!;
        landingImages[i]['acceleration'] = currentSpecs['acceleration']!;

        print('Updated landing image $i with specs from car ${specIndex}: ' +
            'TopSpeed=${landingImages[i]['topSpeed']}, ' +
            'MaxPower=${landingImages[i]['maxPower']}, ' +
            'Engine=${landingImages[i]['engine']}, ' +
            'Acceleration=${landingImages[i]['acceleration']}');
      }

      setState(() {
        isLoading = false;
      });

      print(
          'Data fetch complete. Car models: ${carModels.length}, Landing images: ${landingImages.length}');

      if (carModels.isEmpty && landingImages.isEmpty) {
        setState(() {
          errorMessage = 'No data available. Please try again later.';
        });
        print('Error: No data available after fetch attempts');
      }
    } catch (e) {
      print('Fatal error in fetchData: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double aspectRatio = screenWidth / screenHeight;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'GT40 GenZ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: _adaptiveFontSize(screenWidth, 18, 22),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.message_outlined,
                color: Colors.white,
                size: _adaptiveIconSize(screenWidth),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AdminChatScreen()));
              },
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: _adaptiveIconSize(screenWidth),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationScreen()));
              },
              padding: EdgeInsets.only(right: screenWidth * 0.03),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isLoading)
                    SizedBox(
                      height: screenHeight * 0.4,
                      child: const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white)),
                    )
                  else if (errorMessage != null &&
                      carModels.isEmpty &&
                      landingImages.isEmpty)
                    SizedBox(
                      height: screenHeight * 0.4,
                      child: Center(
                        child: Text(
                          errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else ...[
                    if (landingImages.isNotEmpty)
                      _buildResponsiveBanner(
                          screenWidth, screenHeight, aspectRatio)
                    else
                      SizedBox(
                        height: screenHeight * 0.4,
                        child: const Center(
                          child: Text(
                            'No banner images available',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    SizedBox(
                        height: _adaptiveSpacing(screenHeight, 0.04, 15, 25)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              _adaptivePadding(screenWidth, 0.04, 12, 20)),
                      child: Text(
                        'Available Models',
                        style: TextStyle(
                          fontSize: _adaptiveFontSize(screenWidth, 16, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                        height: _adaptiveSpacing(screenHeight, 0.02, 8, 15)),
                    _buildCarModelsSection(
                        screenWidth, screenHeight, aspectRatio),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveBanner(
      double screenWidth, double screenHeight, double aspectRatio) {
    final double bannerHeight =
        aspectRatio > 0.5 ? screenHeight * 0.35 : screenHeight * 0.4;
    final double adjustedBannerHeight =
        math.min(math.max(bannerHeight, 200.0), 300.0);

    return Stack(
      children: [
        CarouselSlider(
          items: landingImages
              .map((item) => CarBanner(
                    carData: item,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    aspectRatio: aspectRatio,
                  ))
              .toList(),
          options: CarouselOptions(
            height: adjustedBannerHeight,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: landingImages.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentBannerIndex == entry.key
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCarModelsSection(
      double screenWidth, double screenHeight, double aspectRatio) {
    bool useSingleColumn = screenWidth < 360;

    if (carModels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No car models available',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(
          vertical: _adaptiveSpacing(screenHeight, 0.03, 12, 20)),
      child: Column(
        children: [
          // First row with one or two car models
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: _adaptivePadding(screenWidth, 0.04, 12, 20)),
            child: useSingleColumn
                ? Column(
                    children: [
                      if (carModels.isNotEmpty)
                        CarCard(
                          car: carModels[0],
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isFullWidth: true,
                          slug:'Mark-I',
                                                  ),
                      if (carModels.length > 1)
                        SizedBox(
                            height:
                                _adaptiveSpacing(screenHeight, 0.02, 8, 15)),
                      if (carModels.length > 1)
                        CarCard(
                          car: carModels[1],
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isFullWidth: true,
                          slug: 'Mark-II',
                        ),
                    ],
                  )
                : Row(
                    children: [
                      if (carModels.isNotEmpty)
                        Expanded(
                          child: CarCard(
                            car: carModels[0],
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          slug: 'Mark-I',
                          ),
                        ),
                      if (carModels.length > 1)
                        SizedBox(width: screenWidth * 0.04),
                      if (carModels.length > 1)
                        Expanded(
                          child: CarCard(
                            car: carModels[1],
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            slug: 'Mark-II',
                          ),
                        ),
                    ],
                  ),
          ),

          // Third car model - full width regardless of screen size
          if (carModels.length > 2) ...[
            SizedBox(height: _adaptiveSpacing(screenHeight, 0.02, 8, 15)),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: _adaptivePadding(screenWidth, 0.04, 12, 20)),
              child: CarCard(
                car: carModels[2],
                isFullWidth: true,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                slug: 'Mark-IV',
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _adaptiveFontSize(double screenWidth, double min, double max) {
    return math.min(math.max(screenWidth * 0.045, min), max);
  }

  double _adaptiveIconSize(double screenWidth) {
    return math.min(math.max(screenWidth * 0.06, 22), 28);
  }

  double _adaptiveSpacing(
      double screenHeight, double factor, double min, double max) {
    return math.min(math.max(screenHeight * factor, min), max);
  }

  double _adaptivePadding(
      double screenWidth, double factor, double min, double max) {
    return math.min(math.max(screenWidth * factor, min), max);
  }
}

class CarBanner extends StatefulWidget {
  final Map<String, dynamic> carData;
  final double screenWidth;
  final double screenHeight;
  final double aspectRatio;

  const CarBanner({
    Key? key,
    required this.carData,
    required this.screenWidth,
    required this.screenHeight,
    required this.aspectRatio,
  }) : super(key: key);

  @override
  _CarBannerState createState() => _CarBannerState();
}

class _CarBannerState extends State<CarBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = widget.screenWidth < 360;
    final bool isLandscape = widget.aspectRatio > 1.7;

    final double descFontSize =
        math.min(math.max(widget.screenWidth * 0.028, 10), 14);
    final double statLabelFontSize =
        math.min(math.max(widget.screenWidth * 0.018, 7), 9);
    final double statValueFontSize =
        math.min(math.max(widget.screenWidth * 0.026, 9), 12);

    final double carImageWidth =
        isLandscape ? widget.screenWidth * 0.55 : widget.screenWidth * 0.65;
    final double maxCarWidth = 280.0;
    final double adjustedCarWidth = math.min(carImageWidth, maxCarWidth);
    final double carImageHeight = adjustedCarWidth * 0.7;

    final double bannerMaxHeight = 250.0;
    final double bannerMinHeight = 180.0;
    final double calculatedHeight =
        widget.screenHeight * (isLandscape ? 0.30 : 0.35);
    final double responsiveBannerHeight =
        math.min(math.max(calculatedHeight, bannerMinHeight), bannerMaxHeight);

    final double statsContainerHeight =
        math.min(responsiveBannerHeight * 0.3, 80.0);
    final double adjustedStatsHeight =
        isSmallScreen ? statsContainerHeight * 1.4 : statsContainerHeight;

    return Container(
      height: responsiveBannerHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: (widget.carData['gradientColors'] as List<Color>),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: widget.screenHeight * 0.015,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                widget.carData['description'] as String,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            top: widget.screenHeight * 0.06,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Container(
                      width: adjustedCarWidth,
                      height: carImageHeight,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Image.network(
                        widget.carData['image'] as String,
                        width: adjustedCarWidth,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading banner image: $error');
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/car.png',
                                width: adjustedCarWidth * 0.8,
                                fit: BoxFit.contain,
                              ),
                              Text(
                                'Image load error: ${error.toString().substring(0, math.min(50, error.toString().length))}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Loading image...',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: widget.screenWidth * 0.06,
            right: widget.screenWidth * 0.06,
            child: Container(
              height: adjustedStatsHeight,
              padding: EdgeInsets.symmetric(
                vertical: widget.screenHeight * 0.01,
                horizontal: widget.screenWidth * 0.04,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.2),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: isSmallScreen
                  ? _buildCompactStats(statLabelFontSize, statValueFontSize)
                  : _buildRegularStats(statLabelFontSize, statValueFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularStats(double labelFontSize, double valueFontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStat('Top Speed', widget.carData['topSpeed'] as String,
            labelFontSize, valueFontSize),
        _buildStat('Max Power', widget.carData['maxPower'] as String,
            labelFontSize, valueFontSize),
        _buildStat('Engine', widget.carData['engine'] as String, labelFontSize,
            valueFontSize),
        _buildStat('0 - 60 MPH', widget.carData['acceleration'] as String,
            labelFontSize, valueFontSize),
      ],
    );
  }

  Widget _buildCompactStats(double labelFontSize, double valueFontSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStat(
                    'Top Speed',
                    widget.carData['topSpeed'] as String,
                    labelFontSize,
                    valueFontSize),
              ),
              Expanded(
                child: _buildStat(
                    'Max Power',
                    widget.carData['maxPower'] as String,
                    labelFontSize,
                    valueFontSize),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStat('Engine', widget.carData['engine'] as String,
                    labelFontSize, valueFontSize),
              ),
              Expanded(
                child: _buildStat(
                    '0 - 60 MPH',
                    widget.carData['acceleration'] as String,
                    labelFontSize,
                    valueFontSize),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat(
      String title, String value, double titleFontSize, double valueFontSize) {
    final double indicatorWidth =
        math.min(math.max(widget.screenWidth * 0.10, 30), 40);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white70, fontSize: titleFontSize),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
              color: Colors.white,
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Container(
          width: indicatorWidth,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: (widget.carData['gradientColors'] as List<Color>),
            ),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
    );
  }
}

class CarCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final bool isFullWidth;
  final double screenWidth;
  final double screenHeight;
  final String slug;
   
  const CarCard({
    Key? key,
    required this.car,
    this.isFullWidth = false,
    required this.screenWidth,
    required this.screenHeight,
    required this.slug,
   
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = screenWidth < 360;

    final double titleSize = math.min(
        math.max(isFullWidth ? screenWidth * 0.05 : screenWidth * 0.04,
            isFullWidth ? 16 : 14),
        isFullWidth ? 22 : 18);

    final double descSize = math.min(
        math.max(isFullWidth ? screenWidth * 0.035 : screenWidth * 0.03,
            isFullWidth ? 12 : 10),
        isFullWidth ? 16 : 14);

    final double verticalPadding = math.min(
        math.max(screenHeight * (isFullWidth ? 0.018 : 0.014),
            isSmallScreen ? 8 : 10),
        16);

    final Color orderNowColor = Colors.blue;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      padding: EdgeInsets.all(math.min(math.max(screenWidth * 0.03, 12), 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: isFullWidth ? 16 / 7 : 16 / 9,
              child: Image.network(
                car['image'] as String,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading car card image: $error');
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/car.png',
                        fit: BoxFit.contain,
                        height: isFullWidth ? 120 : 100,
                      ),
                      Text(
                        "Image URL: ${car['image']}",
                        style: TextStyle(color: Colors.black, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading ${car['name']}...',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: math.min(math.max(screenHeight * 0.015, 8), 15)),
          Text(
            '${car['name']} - ${car['landingTitle']}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
            ),
          ),
          SizedBox(height: math.min(math.max(screenHeight * 0.005, 3), 6)),
          Text(
            car['description'] as String,
            style: TextStyle(
              color: Colors.white,
              fontSize: descSize,
            ),
          ),
          SizedBox(height: math.min(math.max(screenHeight * 0.02, 10), 18)),
          Center(
            child: SizedBox(
              width: isFullWidth ? screenWidth * 0.5 : screenWidth * 0.7,
              child: _buildButton(
                  'Order Now', orderNowColor, verticalPadding, context,slug,car),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String text, Color color, double verticalPadding, BuildContext context,String slug,  Map<String, dynamic> car) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CarConfiguratorScreen(slug: slug,car: car,)));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: math.min(math.max(screenWidth * 0.03, 12), 16),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
