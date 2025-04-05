import 'package:flutter/material.dart';
import 'screens/wallet_connect/wallet_connect_screen.dart';

class WildApp extends StatelessWidget {
  const WildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'WILD Platform',
      home: WalletConnectScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
