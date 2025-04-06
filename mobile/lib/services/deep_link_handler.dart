import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import '../screens/home_screen.dart'; // Import your HomeScreen
import '../services/api_service.dart'; // Import ApiService if needed

class DeepLinkHandler {
  final ApiService apiService; // Add ApiService as a required parameter

  // Constructor to initialize ApiService
  DeepLinkHandler({required this.apiService});

  Future<void> initUniLinks(BuildContext context) async {
    // Attach a listener to the stream
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleIncomingLink(context, uri);
      }
    }, onError: (err) {
      print('Deep link error: $err'); // Better error handling
    });
  }

  void _handleIncomingLink(BuildContext context, Uri uri) {
    if (uri.scheme == 'phantomlink' || uri.scheme == 'born2bewild') {
      // Extract wallet address or connection details
      final walletAddress = uri.queryParameters['wallet'];

      if (walletAddress != null) {
        // Navigate to home screen or process wallet connection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              walletAddress: walletAddress,
              apiService: apiService, // Pass the ApiService
            ),
          ),
        );
      }
    }
  }
}
