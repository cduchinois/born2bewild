import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phantom Connect',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _connectWithPhantom() async {
    final redirectUri = Uri.encodeComponent("born2bewild://callback");
    final cluster = "devnet";

    final url = Uri.parse(
      "phantom://v1/connect?redirect_uri=$redirectUri&cluster=$cluster",
    );

    print("Trying to launch: $url");

    final fallback = Uri.parse(
        "https://apps.apple.com/app/phantom-solana-wallet/id1598432977");

    // Essaie de lancer Phantom
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print("❌ Could not launch Phantom. Opening App Store.");
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phantom Wallet Connect'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _connectWithPhantom,
          child: const Text("Connect Phantom"),
        ),
      ),
    );
  }
}
