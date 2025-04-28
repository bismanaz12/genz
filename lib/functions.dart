import 'dart:convert';
import 'package:http/http.dart' as http;

// Base API Response model
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

// Car Package Model
class CarPackage {
  final String id;
  final String name;
  final String description;
  final String reserveAmount;
  final String packageType;
  final String baseAmount;
  final String discountAmount;

  CarPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.reserveAmount,
    required this.packageType,
    required this.baseAmount,
    required this.discountAmount,
  });

  factory CarPackage.fromJson(Map<String, dynamic> json) {
    return CarPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      reserveAmount: json['reserveAmount'] ?? '',
      packageType: json['package_type'] ?? '',
      baseAmount: json['baseAmount'] ?? '',
      discountAmount: json['discountAmount'] ?? '',
    );
  }
}

// Landing Image Model
class LandingImage {
  final String id;
  final int section;
  final String title;
  final String subtitle;
  final String image;
  final String webImage;
  final bool isActive;
  final int position;

  LandingImage({
    required this.id,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.webImage,
    required this.isActive,
    required this.position,
  });

  factory LandingImage.fromJson(Map<String, dynamic> json) {
    return LandingImage(
      id: json['id'] ?? '',
      section: json['section'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      webImage: json['web_image'] ?? '',
      isActive: json['is_active'] ?? false,
      position: json['position'] ?? 0,
    );
  }
}

// Nav Item Model
class NavItem {
  final String id;
  final String title;
  final String slug;
  final String content;
  final bool isActive;
  final int position;

  NavItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.isActive,
    required this.position,
  });

  factory NavItem.fromJson(Map<String, dynamic> json) {
    return NavItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      isActive: json['is_active'] ?? false,
      position: json['position'] ?? 0,
    );
  }
}

// Car Model
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
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      estimatedDelivery: json['estimated_delivery'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

// Feature Section Model
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// Feature Model
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      price: json['price'] ?? '',
      option1: json['option1'],
      option2: json['option2'],
      option1Price: json['option1_price'] ?? '',
      option2Price: json['option2_price'] ?? '',
      checked: json['checked'] ?? false,
      disabled: json['disabled'] ?? false,
      included: json['included'] ?? false,
      inRollerPlus: json['in_rollerPlus'] ?? false,
      inMarkI: json['in_mark_I'] ?? false,
      inMarkII: json['in_mark_II'] ?? false,
      inMarkIV: json['in_mark_IV'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      section: json['section'] ?? '',
    );
  }
}

// Payment Model
class Payment {
  final String id;
  final String amount;
  final String currency;
  final String status;
  final String regarding;
  final String createdAt;

  Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.regarding,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      amount: json['amount'] ?? '',
      currency: json['currency'] ?? '',
      status: json['status'] ?? '',
      regarding: json['regarding'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

// Reservation Model
class Reservation {
  final String id;
  final String reservationNumber;
  final String carModel;
  final String package;
  final String price;
  final String status;
  final String buildStatus;
  final String createdAt;
  final String updatedAt;

  Reservation({
    required this.id,
    required this.reservationNumber,
    required this.carModel,
    required this.package,
    required this.price,
    required this.status,
    required this.buildStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? '',
      reservationNumber: json['reservation_number'] ?? '',
      carModel: json['car_model'] ?? '',
      package: json['package'] ?? '',
      price: json['price'] ?? '',
      status: json['status'] ?? '',
      buildStatus: json['build_status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// User Model
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

// LoginCredentials Model
class LoginCredentials {
  final String email;
  final String password;

  LoginCredentials({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// API Service
class CarApiService {
  final String baseUrl;
  String? _authToken;

  CarApiService({required this.baseUrl});

  // Set auth token for authenticated requests
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Helper method for API requests
  Future<Map<String, dynamic>> _request(
    String url, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    http.Response response;
    final uri = Uri.parse('$baseUrl$url');

    switch (method) {
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(
          uri,
          headers: headers,
        );
        break;
      default:
        response = await http.get(
          uri,
          headers: headers,
        );
        break;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'API request failed: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  // Get car packages by slug
  Future<List<CarPackage>> getCarPackages(String slug) async {
    final response = await _request('/dynamic-packages/$slug/');
    final apiResponse = ApiResponse<List<CarPackage>>.fromJson(
      response,
      (data) =>
          (data as List).map((item) => CarPackage.fromJson(item)).toList(),
    );
    return apiResponse.data ?? [];
  }

  // Get landing page images
  Future<List<LandingImage>> getLandingImages() async {
    final response = await _request('/landing-images/');
    final apiResponse = ApiResponse<List<LandingImage>>.fromJson(
      response,
      (data) =>
          (data as List).map((item) => LandingImage.fromJson(item)).toList(),
    );
    return apiResponse.data ?? [];
  }

  // Get navigation items
  Future<List<NavItem>> getNavItems() async {
    final response = await _request('/nav-items/');
    final apiResponse = ApiResponse<List<NavItem>>.fromJson(
      response,
      (data) => (data as List).map((item) => NavItem.fromJson(item)).toList(),
    );
    return apiResponse.data ?? [];
  }

  // Get car details by slug
  Future<Car?> getCarBySlug(String slug) async {
    final response = await _request('/car/$slug/');
    if (response['success'] == true && response['car'] != null) {
      return Car.fromJson(response['car']);
    }
    return null;
  }

  // Get feature sections
  Future<List<FeatureSection>> getFeatureSections() async {
    final response = await _request('/feature-sections/');
    final apiResponse = ApiResponse<List<FeatureSection>>.fromJson(
      response,
      (data) =>
          (data as List).map((item) => FeatureSection.fromJson(item)).toList(),
    );
    return apiResponse.data ?? [];
  }

  // Get features by package type and car slug
  Future<List<Feature>> getFeatures(String packageType, String carSlug) async {
    final response = await _request('/features/$packageType/$carSlug/');
    final apiResponse = ApiResponse<List<Feature>>.fromJson(
      response,
      (data) => (data as List).map((item) => Feature.fromJson(item)).toList(),
    );
    return apiResponse.data ?? [];
  }

  // Get reservation by reservation number
  Future<Map<String, dynamic>?> getReservation(String reservationNumber) async {
    final response = await _request('/reservation/$reservationNumber/');
    if (response['success'] == true) {
      final reservation = Reservation.fromJson(response['reservation']);
      final payments = (response['payments'] as List)
          .map((item) => Payment.fromJson(item))
          .toList();
      return {
        'reservation': reservation,
        'payments': payments,
      };
    }
    return null;
  }

  // User login
  Future<Map<String, dynamic>?> login(LoginCredentials credentials) async {
    final response = await _request(
      '/login/',
      method: 'POST',
      body: credentials.toJson(),
    );

    if (response['success'] == true) {
      final user = User.fromJson(response['user']);
      final message = response['message'] ?? '';

      // You might want to store the token here if it's returned in the response
      // _authToken = response['token'];

      return {
        'user': user,
        'message': message,
      };
    }
    return null;
  }

  // Get current user's reservations (requires authentication)
  Future<dynamic> getUserReservations() async {
    if (_authToken == null) {
      throw Exception('Authentication required for this endpoint');
    }

    return _request('/user-reservations/');
  }
}
