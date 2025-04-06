import 'package:flutter/material.dart';
import 'screens/wallet_connect/wallet_connect_screen.dart';
// import 'screens/wallet_connect/wallet_connect_screen_test.dart';
import 'services/api_service.dart';

void main() {
  runApp(const WildApp());
}

class WildApp extends StatelessWidget {
  const WildApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ApiService with base URL
    final apiService = ApiService(baseUrl: 'http://10.0.2.2:3000');

    return MaterialApp(
      title: 'WILD Sol',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WalletConnectScreen(apiService: apiService),
      debugShowCheckedModeBanner: false,
    );
  }
}
