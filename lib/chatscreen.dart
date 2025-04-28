import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class AdminChatScreen extends StatefulWidget {
  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Sample messages for demonstration
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! How can I help you with your GT40 GenZ today?",
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
    ),
    ChatMessage(
      text:
          "I'm interested in the Mark III model. Can you tell me about the financing options?",
      isUser: true,
      timestamp: DateTime.now().subtract(Duration(minutes: 28)),
    ),
    ChatMessage(
      text:
          "Certainly! For the Mark III, we offer several premium financing plans with rates starting at 2.9% APR for qualified buyers. Would you like me to send you a detailed breakdown?",
      isUser: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 25)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: _messageController.text.trim(),
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );

        // Clear the input field
        _messageController.clear();

        // Simulate admin response after a short delay
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _messages.add(
                ChatMessage(
                  text:
                      "Thank you for your message. An admin will respond shortly.",
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );

              // Scroll to bottom after adding new messages
              _scrollToBottom();
            });
          }
        });
      });

      // Scroll to bottom immediately after user sends message
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive calculations
    final screenSize = MediaQuery.of(context).size;
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final bool isSmallScreen = screenSize.width < 360;
    final double horizontalPadding = isSmallScreen ? 8.0 : 16.0;

    // Calculate bubble width constraints based on screen size
    final double maxBubbleWidth = screenSize.width * 0.75;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: math.min(56, screenSize.height * 0.08),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: isSmallScreen ? 12 : 16,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 4 : 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GT40 Admin Support',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white, size: isSmallScreen ? 20 : 24),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
          constraints: BoxConstraints(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert,
                color: Colors.white, size: isSmallScreen ? 20 : 24),
            onPressed: () {},
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
            constraints: BoxConstraints(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat history
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: math.min(20, screenSize.height * 0.025)),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final showTimestamp = index == 0 ||
                        _messages[index]
                                .timestamp
                                .difference(_messages[index - 1].timestamp)
                                .inMinutes >
                            5;

                    return Column(
                      children: [
                        if (showTimestamp)
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: isSmallScreen ? 8.0 : 16.0,
                                top: isSmallScreen ? 4.0 : 8.0),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8 : 12,
                                    vertical: isSmallScreen ? 2 : 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatTimestamp(message.timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: isSmallScreen ? 10 : 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        MessageBubble(
                          message: message,
                          maxWidth: maxBubbleWidth,
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Message input area
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: math.min(12, screenSize.height * 0.015),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: Colors.white70,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.all(isSmallScreen ? 4.0 : 8.0),
                    constraints: BoxConstraints(),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 8 : 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.black,
                        size: isSmallScreen ? 16 : 20,
                      ),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(timestamp)}';
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final double maxWidth;
  final bool isSmallScreen;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.maxWidth,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaleFactor = isSmallScreen ? 0.8 : 1.0;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Container(
          margin: EdgeInsets.only(
            bottom: 12 * scaleFactor,
            left: message.isUser ? maxWidth * 0.25 : 0,
            right: message.isUser ? 0 : maxWidth * 0.25,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scaleFactor,
            vertical: 12 * scaleFactor,
          ),
          decoration: BoxDecoration(
            color: message.isUser ? Colors.white : Colors.grey[800],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20 * scaleFactor),
              topRight: Radius.circular(20 * scaleFactor),
              bottomLeft: message.isUser
                  ? Radius.circular(20 * scaleFactor)
                  : Radius.circular(4 * scaleFactor),
              bottomRight: message.isUser
                  ? Radius.circular(4 * scaleFactor)
                  : Radius.circular(20 * scaleFactor),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4 * scaleFactor,
                offset: Offset(0, 2 * scaleFactor),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.black : Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: 4 * scaleFactor),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(message.timestamp),
                      style: TextStyle(
                        color: message.isUser ? Colors.black54 : Colors.white70,
                        fontSize: isSmallScreen ? 8 : 10,
                      ),
                    ),
                    if (message.isUser)
                      Padding(
                        padding: EdgeInsets.only(left: 4.0 * scaleFactor),
                        child: Icon(
                          Icons.done_all,
                          size: isSmallScreen ? 12 : 14,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
