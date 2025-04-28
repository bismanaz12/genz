import 'package:flutter/material.dart';
import 'dart:math' as math;

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<DeliveryNotification> notifications = [
    DeliveryNotification(
      carModel: "MARK II",
      status: "Processing",
      message:
          "Your GT40 MARK II order has been received and is being processed.",
      time: DateTime.now().subtract(Duration(days: 1)),
      isRead: false,
    ),
    DeliveryNotification(
      carModel: "MARK II",
      status: "Manufacturing",
      message: "Your GT40 MARK II has entered the manufacturing stage.",
      time: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
    ),
    DeliveryNotification(
      carModel: "MARK I",
      status: "Shipped",
      message: "Your GT40 MARK I has been shipped and is on its way to you.",
      time: DateTime.now().subtract(Duration(days: 5)),
      isRead: true,
    ),
    DeliveryNotification(
      carModel: "MARK III",
      status: "Quality Check",
      message: "Your GT40 MARK III is undergoing final quality checks.",
      time: DateTime.now().subtract(Duration(days: 7)),
      isRead: true,
    ),
    DeliveryNotification(
      carModel: "MARK I",
      status: "Ready for Delivery",
      message:
          "Your GT40 MARK I is ready for delivery. Our team will contact you shortly to schedule the delivery.",
      time: DateTime.now().subtract(Duration(days: 10)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive calculations
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: _adaptiveFontSize(screenWidth, 18, 22),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: _adaptiveIconSize(screenWidth),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: _adaptiveIconSize(screenWidth),
              ),
              onPressed: () {
                // Mark all as read
                setState(() {
                  for (var notification in notifications) {
                    notification.isRead = true;
                  }
                });
              },
              padding: EdgeInsets.only(right: screenWidth * 0.03),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Delivery Status Card
                _buildDeliveryStatusCard(screenWidth, screenHeight),

                SizedBox(height: _adaptiveSpacing(screenHeight, 0.02, 10, 20)),

                // Notification Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _adaptivePadding(screenWidth, 0.04, 12, 20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Updates',
                        style: TextStyle(
                          fontSize: _adaptiveFontSize(screenWidth, 16, 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: _adaptiveFontSize(screenWidth, 14, 16),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: _adaptiveSpacing(screenHeight, 0.01, 5, 10)),

                // Notifications List
                Expanded(
                  child: notifications.isEmpty
                      ? _buildEmptyNotificationState(screenWidth, screenHeight)
                      : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationItem(
                              notifications[index],
                              screenWidth,
                              screenHeight,
                              index == notifications.length - 1,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Delivery Status Card
  Widget _buildDeliveryStatusCard(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _adaptivePadding(screenWidth, 0.04, 12, 20),
        vertical: _adaptiveSpacing(screenHeight, 0.02, 10, 20),
      ),
      padding: EdgeInsets.all(_adaptivePadding(screenWidth, 0.04, 15, 25)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF000046), const Color(0xFF1CB5E0)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GT40 MARK II',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _adaptiveFontSize(screenWidth, 18, 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Manufacturing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _adaptiveFontSize(screenWidth, 12, 14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _adaptiveSpacing(screenHeight, 0.02, 10, 15)),
          _buildDeliveryProgressBar(screenWidth),
          SizedBox(height: _adaptiveSpacing(screenHeight, 0.02, 10, 15)),
          Text(
            'Estimated Delivery: June 15, 2025',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: _adaptiveFontSize(screenWidth, 14, 16),
            ),
          ),
        ],
      ),
    );
  }

  // Delivery Progress Bar
  Widget _buildDeliveryProgressBar(double screenWidth) {
    final List<String> stages = [
      'Order',
      'Manufacturing',
      'Quality Check',
      'Shipping',
      'Delivered'
    ];
    final int currentStage = 1; // Manufacturing stage (0-indexed)

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(stages.length, (index) {
            bool isCompleted = index <= currentStage;
            bool isCurrent = index == currentStage;

            return Container(
              width: screenWidth * 0.04,
              height: screenWidth * 0.04,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
                border: isCurrent
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
            );
          }),
        ),
        SizedBox(height: 6),
        Stack(
          children: [
            // Background line
            Container(
              height: 2,
              color: Colors.white.withOpacity(0.3),
            ),
            // Progress line
            FractionallySizedBox(
              widthFactor: currentStage / (stages.length - 1),
              child: Container(
                height: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(stages.length, (index) {
            bool isCompleted = index <= currentStage;

            return Flexible(
              child: Text(
                stages[index],
                style: TextStyle(
                  color: isCompleted
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  fontSize: _adaptiveFontSize(screenWidth, 10, 12),
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    );
  }

  // Empty Notification State
  Widget _buildEmptyNotificationState(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: screenWidth * 0.15,
            color: Colors.grey,
          ),
          SizedBox(height: _adaptiveSpacing(screenHeight, 0.02, 10, 20)),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: _adaptiveFontSize(screenWidth, 16, 20),
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: _adaptiveSpacing(screenHeight, 0.01, 5, 10)),
          Text(
            'You have no notifications at this time.',
            style: TextStyle(
              fontSize: _adaptiveFontSize(screenWidth, 14, 16),
              color: Colors.grey.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Notification Item
  Widget _buildNotificationItem(DeliveryNotification notification,
      double screenWidth, double screenHeight, bool isLast) {
    return InkWell(
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
        _showNotificationDetails(context, notification, screenWidth);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _adaptivePadding(screenWidth, 0.04, 12, 20),
          vertical: _adaptiveSpacing(screenHeight, 0.02, 12, 18),
        ),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : Colors.grey.withOpacity(0.1),
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(notification.status).withOpacity(0.2),
              ),
              child: Center(
                child: Icon(
                  _getStatusIcon(notification.status),
                  color: _getStatusColor(notification.status),
                  size: screenWidth * 0.06,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Status Update: ${notification.status}',
                          style: TextStyle(
                            fontSize: _adaptiveFontSize(screenWidth, 14, 16),
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: _adaptiveSpacing(screenHeight, 0.01, 4, 8)),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: _adaptiveFontSize(screenWidth, 12, 14),
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _adaptiveSpacing(screenHeight, 0.01, 4, 8)),
                  Wrap(
                    spacing: screenWidth * 0.02,
                    children: [
                      Text(
                        'Model: ${notification.carModel}',
                        style: TextStyle(
                          fontSize: _adaptiveFontSize(screenWidth, 11, 12),
                          color: Colors.grey.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(notification.time),
                        style: TextStyle(
                          fontSize: _adaptiveFontSize(screenWidth, 11, 12),
                          color: Colors.grey.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show notification details
  void _showNotificationDetails(BuildContext context,
      DeliveryNotification notification, double screenWidth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bottomSheetScreenWidth = MediaQuery.of(context).size.width;
        final bottomSheetScreenHeight = MediaQuery.of(context).size.height;

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: bottomSheetScreenHeight * 0.7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status Update',
                      style: TextStyle(
                        fontSize:
                            _adaptiveFontSize(bottomSheetScreenWidth, 18, 22),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildNotificationDetailItem(
                  'Car Model:',
                  notification.carModel,
                  bottomSheetScreenWidth,
                ),
                _buildNotificationDetailItem(
                  'Status:',
                  notification.status,
                  bottomSheetScreenWidth,
                ),
                _buildNotificationDetailItem(
                  'Date:',
                  _formatDate(notification.time),
                  bottomSheetScreenWidth,
                ),
                SizedBox(height: 15),
                Text(
                  'Details:',
                  style: TextStyle(
                    fontSize: _adaptiveFontSize(bottomSheetScreenWidth, 16, 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: _adaptiveFontSize(bottomSheetScreenWidth, 14, 16),
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStatusColor(notification.status),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize:
                            _adaptiveFontSize(bottomSheetScreenWidth, 14, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Notification detail item
  Widget _buildNotificationDetailItem(
      String label, String value, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.25,
            child: Text(
              label,
              style: TextStyle(
                fontSize: _adaptiveFontSize(screenWidth, 14, 16),
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: _adaptiveFontSize(screenWidth, 14, 16),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.amber;
      case 'Manufacturing':
        return Colors.blue;
      case 'Quality Check':
        return Colors.purple;
      case 'Shipped':
        return Colors.green;
      case 'Ready for Delivery':
        return Colors.orange;
      case 'Delivered':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Processing':
        return Icons.receipt_outlined;
      case 'Manufacturing':
        return Icons.precision_manufacturing_outlined;
      case 'Quality Check':
        return Icons.check_circle_outline;
      case 'Shipped':
        return Icons.local_shipping_outlined;
      case 'Ready for Delivery':
        return Icons.inventory_2_outlined;
      case 'Delivered':
        return Icons.done_all;
      default:
        return Icons.notification_important_outlined;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime time) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[time.month - 1]} ${time.day}, ${time.year} at ${_formatTime(time)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }

  // Adaptive sizing helpers
  double _adaptiveFontSize(double screenWidth, double min, double max) {
    return math.min(math.max(screenWidth * 0.04, min), max);
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

// Notification data class
class DeliveryNotification {
  final String carModel;
  final String status;
  final String message;
  final DateTime time;
  bool isRead;

  DeliveryNotification({
    required this.carModel,
    required this.status,
    required this.message,
    required this.time,
    required this.isRead,
  });
}
