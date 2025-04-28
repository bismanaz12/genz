import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:developer' as developer; // For logging

// FeatureResponse and Feature classes (as provided)
class FeatureResponse {
  final bool success;
  final List<Feature> data;

  FeatureResponse({required this.success, required this.data});

  factory FeatureResponse.fromJson(Map<String, dynamic> json) {
    return FeatureResponse(
      success: json['success'],
      data:
          (json['data'] as List).map((item) => Feature.fromJson(item)).toList(),
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
  final bool checked;
  final bool disabled;
  final bool included;
  final bool inRollerPlus;
  final bool inMarkI;
  final bool inMarkII;
  final bool inMarkIV;
  final String createdAt;
  final String updatedAt;
  final String section;

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
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      price: json['price'],
      option1: json['option1'],
      option2: json['option2'],
      option1Price: json['option1_price'],
      option2Price: json['option2_price'],
      checked: json['checked'],
      disabled: json['disabled'],
      included: json['included'],
      inRollerPlus: json['in_rollerPlus'],
      inMarkI: json['in_mark_I'],
      inMarkII: json['in_mark_II'],
      inMarkIV: json['in_mark_IV'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      section: json['section'],
    );
  }
}

// Modified ApiService to support dynamic package and slug
class ApiService {
  static const String baseUrl = 'http://178.128.150.238';

  Future<FeatureResponse> getFeatures(String package, String slug) async {
    final url = Uri.parse('$baseUrl/auth/api/features/$package/$slug/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add 'Authorization': 'Bearer $token' if needed
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        developer.log('Car features are $responseData');
        return FeatureResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load features: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching features: $e');
    }
  }
}

class CarConfiguratorScreen extends StatefulWidget {
  const CarConfiguratorScreen({Key? key}) : super(key: key);

  @override
  State<CarConfiguratorScreen> createState() => _CarConfiguratorScreenState();
}

class _CarConfiguratorScreenState extends State<CarConfiguratorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String selectedPackage = 'roller'; // Matches API package type
  String carSlug = 'Mark-I'; // Matches API slug
  double totalPrice = 22000.00;
  List<Feature> features = [];
  bool isLoading = false;
  String? errorMessage;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    fetchFeatures();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fetch features from API
  Future<void> fetchFeatures() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final featureResponse =
          await apiService.getFeatures(selectedPackage, carSlug);
      if (featureResponse.success) {
        setState(() {
          features = featureResponse.data;
          isLoading = false;
          updateTotalPrice(); // Update price based on features
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load features';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Group features by section
  Map<String, List<Feature>> groupFeaturesBySection() {
    final grouped = <String, List<Feature>>{};
    for (var feature in features) {
      grouped.putIfAbsent(feature.section, () => []).add(feature);
    }
    return grouped;
  }

  // Update total price based on selected features
  void updateTotalPrice() {
    double price = 22000.00; // Base price
    for (var feature in features) {
      if (feature.included) {
        price += double.tryParse(feature.price) ?? 0;
      }
      // Add logic for selected options (option1 or option2) if needed
    }
    setState(() {
      totalPrice = price;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Mark I Configurator',
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
                  'Configure Your Mark I',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: PackageButton(
                        title: 'Roller',
                        isSelected: selectedPackage == 'roller',
                        onTap: () {
                          setState(() => selectedPackage = 'roller');
                          fetchFeatures();
                        },
                      ),
                    ),
                    Flexible(
                      child: PackageButton(
                        title: 'Roller Platinum',
                        isSelected: selectedPackage == 'rollerPlus',
                        onTap: () {
                          setState(() => selectedPackage = 'rollerPlus');
                          fetchFeatures();
                        },
                      ),
                    ),
                    Flexible(
                      child: PackageButton(
                        title: 'Builder Package',
                        isSelected: selectedPackage == 'builder',
                        onTap: () {
                          setState(() => selectedPackage = 'builder');
                          fetchFeatures();
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.03),

                SizedBox(
                  height: isLandscape ? size.height * 0.35 : size.height * 0.3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (_, child) {
                        final rotation = _controller.value * 2 * math.pi;
                        final scale =
                            1.0 + 0.1 * math.sin(_controller.value * math.pi);
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(rotation)
                            ..scale(scale),
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/images/car.png',
                        width: size.width * 0.8,
                        height: size.height * 0.22,
                        fit: BoxFit.contain,
                      ),
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
                  'Customize your dream car!',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 225, 224, 224),
                    fontSize: size.width * 0.032,
                  ),
                  textAlign: TextAlign.center,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.01),
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
                        '\$25000.00',
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

                const Divider(color: Colors.grey),

                // Dynamic Features
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (errorMessage != null)
                  Column(
                    children: [
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      ElevatedButton(
                        onPressed: fetchFeatures,
                        child: Text('Retry'),
                      ),
                    ],
                  )
                else
                  ...groupFeaturesBySection().entries.map((entry) {
                    return ConfigSection(
                      title: entry.key,
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
                          hasOptions: feature.option1 != null ||
                              feature.option2 != null,
                          buildOption: feature.option1 != null ||
                                  feature.option2 != null
                              ? (context) {
                                  String? selectedOption = feature.option1;
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              groupValue: selectedOption,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedOption = value;
                                                  // Update totalPrice if needed
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
                                              groupValue: selectedOption,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedOption = value;
                                                  // Update totalPrice if needed
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

                // Payment Schedule (unchanged)
                Container(
                  margin: EdgeInsets.all(size.width * 0.025),
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                        left: BorderSide(color: Colors.blueAccent, width: 4)),
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
                          Text('• ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              '40% WHEN YOUR ORDER BEGINS',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                          Text('• ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              '40% MID WAY (ABOUT 6-8 WEEKS FROM THE ORDER)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                          Text('• ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              'BALANCE WHEN YOUR CAR IS READY FOR DELIVERY',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                          Text('— ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              'THIS RESERVATION WILL SAVE YOUR PLACE IN LINE',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                          Text('— ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * 0.04)),
                          Expanded(
                            child: Text(
                              'YOU WILL BE INVITED WHEN YOUR GENZ40 IS READY TO GO IN PRODUCTION',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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

                // Price Summary
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.01),
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
                            'Includes Destination and Order Fee',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 225, 224, 224),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                          Text('',
                              style: Theme.of(context).textTheme.bodyMedium),
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
                            '\$100.00',
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
                            '\$100.00',
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
                          onPressed: () {},
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

// PackageButton (unchanged from original)
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
        padding:
            EdgeInsets.symmetric(vertical: size.height * 0.015, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.2)
              : Colors.grey.shade900,
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

// ConfigSection (unchanged from original)
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
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04, vertical: size.height * 0.01),
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

// ConfigItem (slightly modified to handle API data)
class ConfigItem extends StatelessWidget {
  final String title;
  final bool isIncluded;
  final String? availableIn;
  final double? price;
  final bool hasOptions;
  final Widget Function(BuildContext)? buildOption;

  const ConfigItem({
    Key? key,
    required this.title,
    required this.isIncluded,
    this.availableIn,
    this.price,
    this.hasOptions = false,
    this.buildOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: size.height * 0.005, horizontal: size.width * 0.025),
      padding: EdgeInsets.symmetric(
          vertical: size.height * 0.01, horizontal: size.width * 0.04),
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
              Container(
                width: size.width * 0.06,
                height: size.width * 0.06,
                decoration: BoxDecoration(
                  color: isIncluded ? Colors.blueAccent : Colors.grey.shade300,
                  border: Border.all(color: Colors.grey.shade600),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: isIncluded
                    ? Icon(Icons.check,
                        color: Colors.white, size: size.width * 0.045)
                    : null,
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
              padding: EdgeInsets.only(
                  left: size.width * 0.09, top: size.height * 0.005),
              child: buildOption!(context),
            ),
        ],
      ),
    );
  }
}
