import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home_screen.dart';
import '../../services/api_service.dart';

class WalletConnectScreen extends StatefulWidget {
  final ApiService apiService;

  const WalletConnectScreen({
    super.key,
    required this.apiService,
  });

  @override
  _WalletConnectScreenState createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
  bool _isConnecting = false;

  Future<void> _connectWallet() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      // Attempt to launch Phantom wallet directly
      final phantomUri = Uri.parse('phantom://');

      if (await canLaunchUrl(phantomUri)) {
        // Launch Phantom wallet
        await launchUrl(phantomUri, mode: LaunchMode.externalApplication);

        // Wait a bit to allow wallet connection
        await Future.delayed(const Duration(seconds: 3));

        // Navigate to HomeScreen with a mock wallet address
        // In a real implementation, you'd retrieve the actual wallet address
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              walletAddress:
                  'bosq5LCREmQ4aiSwzYdvD7N1thoASZzHVqvCA1D2Cg5', // Replace with actual wallet address
              apiService: widget.apiService,
            ),
          ),
        );
      } else {
        // Fallback if Phantom app is not installed
        final appStoreUri = Uri.parse(
            'https://apps.apple.com/app/phantom-crypto-wallet/id1574741552');
        await launchUrl(appStoreUri, mode: LaunchMode.externalApplication);

        setState(() {
          _isConnecting = false;
        });

        // Show a message to install Phantom wallet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please install Phantom Wallet from the App Store'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallet connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/1.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Application logo
                Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                // Wallet connection button
                _isConnecting
                    ? Column(
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Connecting to Solana Wallet...',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
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
                          backgroundColor:
                              const Color.fromARGB(255, 103, 218, 198),
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

                const SizedBox(height: 40),

                // Texts
                Text(
                  'Born 2 be Wild',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Powered by Solana',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
