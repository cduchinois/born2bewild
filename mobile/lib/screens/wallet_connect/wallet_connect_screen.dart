import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  _WalletConnectScreenState createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
  final String _fakeWalletAddress =
      'GxE7m4B5WXqEq1EjUQmuMkJNRRrJFseRg9H7ePpiZT6b';

  bool _isConnecting = false;

  void _connectWallet() {
    setState(() {
      _isConnecting = true;
    });

    // Simulate connection delay
    Future.delayed(const Duration(seconds: 2), () {
      // Navigate to home screen after "connection"
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(walletAddress: _fakeWalletAddress),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.7),
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder - replace with your asset
              const FlutterLogo(size: 200),
              const SizedBox(height: 30),
              Text(
                'WILD Platform',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                'Protecting Animals Through Blockchain',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _isConnecting
                  ? Column(
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Connecting to Solana Wallet...',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _connectWallet,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        'Connect Solana Wallet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
