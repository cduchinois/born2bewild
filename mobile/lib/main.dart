import 'package:flutter/material.dart';
import 'screens/wallet_connect/wallet_connect_screen.dart';

void main() {
  runApp(const WildApp());
}

class WildApp extends StatelessWidget {
  const WildApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WILD Platform',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WalletConnectScreen(), // Start with wallet connect screen
      debugShowCheckedModeBanner: false,
    );
  }
}
