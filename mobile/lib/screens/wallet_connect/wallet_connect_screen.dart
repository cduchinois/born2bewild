import 'package:flutter/material.dart';
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
  final String _fakeWalletAddress =
      'bosq5LCREmQ4aiSwzYdvD7N1thoASZzHVqvCA1D2Cg5';

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
          builder: (context) => HomeScreen(
            walletAddress: _fakeWalletAddress,
            apiService: widget.apiService,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image d'arrière-plan sans voile transparent
          Image.asset(
            'assets/images/1.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de l'application
                Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                // Bouton de connexion au wallet (placé avant les textes)
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

                // Textes placés après le bouton
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
