import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

// Data Models (unchanged)
class Package {
  final String id;
  final String name;
  final String description;
  final String reserveAmount;
  final String packageType;
  final String baseAmount;
  final String discountAmount;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.reserveAmount,
    required this.packageType,
    required this.baseAmount,
    required this.discountAmount,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      reserveAmount: json['reserveAmount']?.toString() ?? '0.00',
      packageType: json['package_type']?.toString() ?? '',
      baseAmount: json['baseAmount']?.toString() ?? '0.00',
      discountAmount: json['discountAmount']?.toString() ?? '0.00',
    );
  }
}

class Car {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String estimatedDelivery;
  final bool isActive;

  Car({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.estimatedDelivery,
    required this.isActive,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      estimatedDelivery: json['estimated_delivery']?.toString() ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

class FeatureSection {
  final String id;
  final String name;
  final String description;

  FeatureSection({
    required this.id,
    required this.name,
    required this.description,
  });

  factory FeatureSection.fromJson(Map<String, dynamic> json) {
    return FeatureSection(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class FeatureResponse {
  final bool success;
  final List<Feature> data;

  FeatureResponse({required this.success, required this.data});

  factory FeatureResponse.fromJson(Map<String, dynamic> json) {
    return FeatureResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Feature.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class Feature {
  final String id;
  final String name;
  final String type;
  final String price;
  final String? option1;
  final String? option2;
  final String option1Price;
  final String option2Price;
  bool checked;
  final bool disabled;
  final bool included;
  final bool inRollerPlus;
  final bool inMarkI;
  final bool inMarkII;
  final bool inMarkIV;
  final String createdAt;
  final String updatedAt;
  final String section;
  String? selectedOption;

  Feature({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.option1,
    this.option2,
    required this.option1Price,
    required this.option2Price,
    required this.checked,
    required this.disabled,
    required this.included,
    required this.inRollerPlus,
    required this.inMarkI,
    required this.inMarkII,
    required this.inMarkIV,
    required this.createdAt,
    required this.updatedAt,
    required this.section,
    this.selectedOption,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      option1: json['option1']?.toString(),
      option2: json['option2']?.toString(),
      option1Price: json['option1_price']?.toString() ?? '0.00',
      option2Price: json['option2_price']?.toString() ?? '0.00',
      checked: json['checked'] ?? false,
      disabled: json['disabled'] ?? false,
      included: json['included'] ?? false,
      inRollerPlus: json['in_rollerPlus'] ?? false,
      inMarkI: json['in_mark_I'] ?? false,
      inMarkII: json['in_mark_II'] ?? false,
      inMarkIV: json['in_mark_IV'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      selectedOption: json['option1']?.toString(),
    );
  }
}

// ApiService (enhanced error handling)
class ApiService {
  static const String baseUrl = 'http://178.128.150.238';

  String ensureCompleteImageUrl(String? imagePath) {
    if (imagePath == null) return '';
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$baseUrl$imagePath';
  }

  Future<FeatureResponse> getFeatures(String package, String slug) async {
    final url = Uri.parse('$baseUrl/auth/api/features/$package/$slug/');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        log('Car features for $package/$slug: $responseData');
        return FeatureResponse.fromJson(responseData);
      } else {
        log('Failed to load features for $package/$slug: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load features: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching features for $package/$slug: $e');
      throw Exception('Error fetching features: $e');
    }
  }

  Future<List<Package>> getPackages(String slug) async {
    final url = Uri.parse('$baseUrl/auth/api/dynamic-packages/$slug/');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        log('Packages for $slug: $responseData');
        if (responseData['success'] == true) {
          return (responseData['data'] as List<dynamic>)
              .map((item) => Package.fromJson(item))
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load packages: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching packages: $e');
      throw Exception('Error fetching packages: $e');
    }
  }

  Future<Car> getCarDetails(String slug) async {
    final url = Uri.parse('$baseUrl/auth/api/car/$slug/');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['car'] != null) {
          return Car.fromJson(responseData['car']);
        } else {
          throw Exception('API returned success: false or no car data');
        }
      } else {
        throw Exception('Failed to load car details: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching car details: $e');
      throw Exception('Error fetching car details: $e');
    }
  }

  Future<List<FeatureSection>> getFeatureSections() async {
    final url = Uri.parse('$baseUrl/auth/api/feature-sections/');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        log('Feature sections: $responseData');
        if (responseData['success'] == true) {
          return (responseData['data'] as List<dynamic>)
              .map((item) => FeatureSection.fromJson(item))
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load feature sections: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching feature sections: $e');
      throw Exception('Error fetching feature sections: $e');
    }
  }

  Future<bool> submitReservation({
    required String carModel,
    required String package,
    required double price,
    required List<Feature> selectedFeatures,
  }) async {
    final url = Uri.parse('$baseUrl/auth/api/reservation/create/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'car_model': carModel,
          'package': package,
          'price': price.toString(),
          'features': selectedFeatures
              .map((f) => {
                    'id': f.id,
                    'name': f.name,
                    'selected_option': f.selectedOption,
                  })
              .toList(),
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        log('Reservation response: $responseData');
        return true;
      } else {
        log('Failed to submit reservation: ${response.body}');
        throw Exception('Failed to submit reservation: ${response.statusCode}');
      }
    } catch (e) {
      log('Error submitting reservation: $e');
      throw Exception('Error submitting reservation: $e');
    }
  }
}

// CarConfiguratorScreen
class CarConfiguratorScreen extends StatefulWidget {
  const CarConfiguratorScreen({Key? key, required this.slug, required this.car})
      : super(key: key);
  final String slug;
  final Map<String, dynamic> car;

  @override
  State<CarConfiguratorScreen> createState() => _CarConfiguratorScreenState();
}

class _CarConfiguratorScreenState extends State<CarConfiguratorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String selectedPackage = 'roller';
  double totalPrice = 0.0;
  List<Feature> features = [];
  List<Package> packages = [];
  Car? car;
  List<FeatureSection> featureSections = [];
  bool isLoading = false;
  String? errorMessage;
  final ApiService apiService = ApiService();
  String? carImageUrl;
  String? lastValidPackage; // Track last valid package
  List<Feature> lastValidFeatures = []; // Store last valid features

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    carImageUrl = apiService.ensureCompleteImageUrl(widget.car['image'] as String?);
    lastValidPackage = selectedPackage;
    fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch features, fallback to last valid features if fails
      FeatureResponse featureResponse;
      try {
        featureResponse = await apiService.getFeatures(selectedPackage, widget.slug);
        setState(() {
          features = featureResponse.data;
          lastValidFeatures = features; // Update last valid features
          lastValidPackage = selectedPackage; // Update last valid package
        });
      } catch (e) {
        log('Failed to fetch features for $selectedPackage, using last valid features');
        features = lastValidFeatures; // Use last valid features
        errorMessage = 'Features unavailable for this package. Showing last valid configuration.';
      }

      final packageResponse = await apiService.getPackages(widget.slug);
      final carResponse = await apiService.getCarDetails(widget.slug);
      final sectionResponse = await apiService.getFeatureSections();

      setState(() {
        packages = packageResponse;
        car = carResponse;
        featureSections = sectionResponse;
        isLoading = false;
        updateTotalPrice();
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void updateTotalPrice() {
    final selectedPackageData = packages.firstWhere(
      (p) => p.packageType == selectedPackage,
      orElse: () => Package(
        id: '',
        name: 'Default Package',
        description: '',
        reserveAmount: '100.00',
        packageType: selectedPackage,
        baseAmount: '22000.00',
        discountAmount: '25000.00',
      ),
    );
    double price = double.tryParse(selectedPackageData.baseAmount) ?? 22000.00;
    for (var feature in features) {
      if (feature.included || feature.checked) {
        price += double.tryParse(feature.price) ?? 0.0;
        if (feature.type == 'radiobox' && feature.selectedOption != null) {
          if (feature.selectedOption == feature.option1) {
            price += double.tryParse(feature.option1Price) ?? 0.0;
          } else if (feature.selectedOption == feature.option2) {
            price += double.tryParse(feature.option2Price) ?? 0.0;
          }
        }
      }
    }
    setState(() {
      totalPrice = price;
    });
  }

  Map<String, List<Feature>> groupFeaturesBySection() {
    final grouped = <String, List<Feature>>{};
    for (var feature in features) {
      grouped.putIfAbsent(feature.section, () => []).add(feature);
    }
    return grouped;
  }

  String getSectionName(String sectionId) {
    final section = featureSections.firstWhere(
      (s) => s.id == sectionId,
      orElse: () => FeatureSection(id: sectionId, name: 'Unknown Section', description: ''),
    );
    return section.name;
  }

  Future<void> reserveCar() async {
    try {
      final success = await apiService.submitReservation(
        carModel: widget.slug,
        package: selectedPackage,
        price: totalPrice,
        selectedFeatures: features.where((f) => f.included || f.checked).toList(),
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation successful!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reserve: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.car['name']?.toString() ?? 'Car Configurator',
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              padding: EdgeInsets.all(size.width * 0.04),
              children: [
                SizedBox(height: size.height * 0.02),
                Text(
                  'Configure Your ${widget.car['name'] ?? "Car"}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.048,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Select your package',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 225, 224, 224),
                    fontSize: size.width * 0.035,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.02),
                // Package Selection
                if (packages.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: packages.map((package) {
                      return Flexible(
                        child: PackageButton(
                          title: package.name,
                          isSelected: selectedPackage == package.packageType,
                          onTap: () {
                            setState(() {
                              selectedPackage = package.packageType;
                            });
                            fetchData();
                          },
                        ),
                      );
                    }).toList(),
                  )
                else
                  const Center(child: Text('No packages available', style: TextStyle(color: Colors.white))),
                SizedBox(height: size.height * 0.03),
                // Car Image and Estimated Delivery
                SizedBox(
                  height: isLandscape ? size.height * 0.35 : size.height * 0.3,
                  child: Center(
                    child: Column(
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (_, child) {
                              final rotation = _controller.value * 2 * math.pi;
                              final scale = 1.0 + 0.1 * math.sin(_controller.value * math.pi);
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(rotation)
                                  ..scale(scale),
                                child: child,
                              );
                            },
                            child: Image.network(
                              carImageUrl ?? 'assets/images/car.png',
                              width: size.width * 0.8,
                              height: size.height * 0.22,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/car.png',
                                  width: size.width * 0.8,
                                  height: size.height * 0.22,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        ),
                        if (car?.estimatedDelivery != null && car!.estimatedDelivery.isNotEmpty)
                          Text(
                            'Est. Delivery: ${car!.estimatedDelivery}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: size.width * 0.035,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Text(
                  '${selectedPackage.replaceFirst(selectedPackage[0], selectedPackage[0].toUpperCase())} Package Configurator',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 250, 247, 247),
                    fontSize: size.width * 0.045,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  widget.car['description']?.toString() ?? 'Customize your dream car!',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 225, 224, 224),
                    fontSize: size.width * 0.032,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Price Display
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05, vertical: size.height * 0.01),
                  child: Row(
                    children: [
                      Text(
                        'Price: ',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 246, 244, 244),
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${packages.firstWhere((p) => p.packageType == selectedPackage, orElse: () => Package(id: '', name: '', description: '', reserveAmount: '100.00', packageType: selectedPackage, baseAmount: '22000.00', discountAmount: '25000.00')).discountAmount}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: size.width * 0.04,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: size.width * 0.025),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Car Specs from Dashboard
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05, vertical: size.height * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Specifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top Speed',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                          Text(
                            widget.car['topSpeed']?.toString() ?? 'N/A',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Max Power',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                          Text(
                            widget.car['maxPower']?.toString() ?? 'N/A',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Engine',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                          Text(
                            widget.car['engine']?.toString() ?? 'N/A',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0-60 MPH',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                          Text(
                            widget.car['acceleration']?.toString() ?? 'N/A',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Dynamic Features
                if (isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.white))
                else if (errorMessage != null)
                  Column(
                    children: [
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.yellow, // Changed to yellow for warning
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      ElevatedButton(
                        onPressed: fetchData,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                else
                  ...groupFeaturesBySection().entries.map((entry) {
                    return ConfigSection(
                      title: getSectionName(entry.key),
                      items: entry.value.map((feature) {
                        return ConfigItem(
                          title: feature.name,
                          isIncluded: feature.included,
                          availableIn: !feature.included
                              ? feature.inRollerPlus
                                  ? 'Available in Roller Plus'
                                  : feature.inMarkII
                                      ? 'Available in Mark II'
                                      : feature.inMarkIV
                                          ? 'Available in Mark IV'
                                          : null
                              : null,
                          price: double.tryParse(feature.price),
                          hasOptions: feature.option1 != null || feature.option2 != null,
                          isDisabled: feature.disabled,
                          isChecked: feature.checked,
                          onCheckedChanged: feature.disabled
                              ? null
                              : (value) {
                                  setState(() {
                                    feature.checked = value!;
                                    updateTotalPrice();
                                  });
                                },
                          buildOption: feature.option1 != null || feature.option2 != null
                              ? (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (feature.option1 != null)
                                            RadioListTile<String>(
                                              title: Text(
                                                '${feature.option1} (\$${feature.option1Price})',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: size.width * 0.035,
                                                ),
                                              ),
                                              value: feature.option1!,
                                              groupValue: feature.selectedOption,
                                              onChanged: feature.disabled
                                                  ? null
                                                  : (value) {
                                                      setState(() {
                                                        feature.selectedOption = value;
                                                        updateTotalPrice();
                                                      });
                                                    },
                                              activeColor: Colors.blueAccent,
                                            ),
                                          if (feature.option2 != null)
                                            RadioListTile<String>(
                                              title: Text(
                                                '${feature.option2} (\$${feature.option2Price})',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: size.width * 0.035,
                                                ),
                                              ),
                                              value: feature.option2!,
                                              groupValue: feature.selectedOption,
                                              onChanged: feature.disabled
                                                  ? null
                                                  : (value) {
                                                      setState(() {
                                                        feature.selectedOption = value;
                                                        updateTotalPrice();
                                                      });
                                                    },
                                              activeColor: Colors.blueAccent,
                                            ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              : null,
                        );
                      }).toList(),
                    );
                  }),
                // Payment Schedule (static, as no API data provided)
                Container(
                  margin: EdgeInsets.all(size.width * 0.025),
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(left: BorderSide(color: Colors.blueAccent, width: 4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Schedule Note',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: size.width * 0.045,
                            ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        children: [
                          Text('• ', style: TextStyle(color: Colors.black, fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              '40% WHEN YOUR ORDER BEGINS',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontSize: size.width * 0.035,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.005),
                      Row(
                        children: [
                          Text('• ', style: TextStyle(color: Colors.black, fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              '40% MID WAY (ABOUT 6-8 WEEKS FROM THE ORDER)',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontSize: size.width * 0.035,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.005),
                      Row(
                        children: [
                          Text('• ', style: TextStyle(color: Colors.black, fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              'BALANCE WHEN YOUR CAR IS READY FOR DELIVERY',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontSize: size.width * 0.035,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.015),
                      const Divider(color: Colors.grey),
                      Row(
                        children: [
                          Text('— ', style: TextStyle(color: Colors.black, fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              'THIS RESERVATION WILL SAVE YOUR PLACE IN LINE',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontSize: size.width * 0.035,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.005),
                      Row(
                        children: [
                          Text('— ', style: TextStyle(color: Colors.black, fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              'YOU WILL BE INVITED WHEN YOUR GENZ40 IS READY TO GO IN PRODUCTION',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontSize: size.width * 0.035,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price Summary (partially dynamic)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05, vertical: size.height * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Est. Purchase Price',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 225, 224, 224),
                          fontSize: size.width * 0.032,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Est. Purchase Price',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.005),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'After Federal Tax Credit if eligible',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}', // No tax logic in API
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.005),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Includes Destination and Order Fee',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                          const Text(''),
                        ],
                      ),
                      SizedBox(height: size.height * 0.005),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Non-refundable Order Fee',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                          Text(
                            '\$${packages.firstWhere((p) => p.packageType == selectedPackage, orElse: () => Package(id: '', name: '', description: '', reserveAmount: '100.00', packageType: selectedPackage, baseAmount: '22000.00', discountAmount: '25000.00')).reserveAmount}',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Due Today',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                          Text(
                            '\$${packages.firstWhere((p) => p.packageType == selectedPackage, orElse: () => Package(id: '', name: '', description: '', reserveAmount: '100.00', packageType: selectedPackage, baseAmount: '22000.00', discountAmount: '25000.00')).reserveAmount}',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.06,
                        child: ElevatedButton(
                          onPressed: reserveCar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Reserve',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.03),
              ],
            );
          },
        ),
      ),
    );
  }
}

// PackageButton (unchanged)
class PackageButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const PackageButton({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
        padding: EdgeInsets.symmetric(vertical: size.height * 0.015, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blueAccent : Colors.transparent,
              width: 3,
            ),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: size.width * 0.04,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ConfigSection (unchanged)
class ConfigSection extends StatelessWidget {
  final String title;
  final List<ConfigItem> items;

  const ConfigSection({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.01),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontSize: size.width * 0.045,
                ),
          ),
        ),
        ...items,
        const Divider(color: Colors.grey),
      ],
    );
  }
}

// ConfigItem (unchanged)
class ConfigItem extends StatelessWidget {
  final String title;
  final bool isIncluded;
  final String? availableIn;
  final double? price;
  final bool hasOptions;
  final bool isDisabled;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckedChanged;
  final Widget Function(BuildContext)? buildOption;

  const ConfigItem({
    Key? key,
    required this.title,
    required this.isIncluded,
    this.availableIn,
    this.price,
    this.hasOptions = false,
    this.isDisabled = false,
    this.isChecked = false,
    this.onCheckedChanged,
    this.buildOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.005, horizontal: size.width * 0.025),
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: size.width * 0.06,
                height: size.width * 0.06,
                child: Checkbox(
                  value: isIncluded || isChecked,
                  onChanged: onCheckedChanged,
                  activeColor: Colors.blueAccent,
                  checkColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
              ),
              SizedBox(width: size.width * 0.025),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        fontSize: size.width * 0.035,
                      ),
                ),
              ),
              if (isIncluded)
                Text(
                  'Included',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontSize: size.width * 0.035,
                      ),
                ),
              if (availableIn != null && !isIncluded)
                Text(
                  availableIn!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blueAccent,
                        fontSize: size.width * 0.035,
                      ),
                ),
              if (price != null && !isIncluded)
                Text(
                  '+\$${price!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blueAccent,
                        fontSize: size.width * 0.035,
                      ),
                ),
            ],
          ),
          if (hasOptions && buildOption != null)
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.09, top: size.height * 0.005),
              child: buildOption!(context),
            ),
        ],
      ),
    );
  }
}