import 'package:flutter/material.dart';
import 'screens/wallet_connect/wallet_connect_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const WildApp());
}

class WildApp extends StatelessWidget {
  const WildApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize ApiService with base URL
    final apiService = ApiService(baseUrl: 'https://api.wildsol.app');

    return MaterialApp(
      title: 'WILD Sol',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WalletConnectScreen(
          apiService: apiService), // Pass apiService to the first screen
      debugShowCheckedModeBanner: false,
    );
  }
}
