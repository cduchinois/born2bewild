import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  final String walletAddress;
  final ApiService apiService;

  const HomeScreen({
    super.key,
    required this.walletAddress,
    required this.apiService,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Bottom navigation index
  int _selectedIndex = 0;

  // Bottom navigation handler
  void _onItemTapped(int index) {
    if (index == 2) {
      // Scan tab - navigate to VerificationScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanScreen(
            apiService: widget.apiService,
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WILD Sol'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.walletAddress));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wallet address copied')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Card
              _buildWalletCard(),

              const SizedBox(height: 20),

              // Platform Features
              Text(
                'WILD Platform Features',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 10),

              // Feature Cards
              _buildFeatureCard(
                icon: Icons.pets,
                title: 'KYA: Know Your Animal',
                description:
                    'AI-powered facial recognition for animal identity tracking',
              ),
              _buildFeatureCard(
                icon: Icons.security,
                title: 'Decentralized ID',
                description:
                    'Track life history and care records for animals on-chain',
              ),
              _buildFeatureCard(
                icon: Icons.monetization_on,
                title: 'Fundraising',
                description:
                    'One-click token launch for vets, NGOs, zoos, and sanctuaries',
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // Important pour afficher plus de 3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Campaign',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Wallet Information Card
  Widget _buildWalletCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rain Forest Alliance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Address: ${widget.walletAddress}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$WILD Balance: 19.800',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4), // Espacement entre les lignes
                    Text(
                      'Animal protected: 42',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4), // Espacement entre les lignes
                    Text(
                      'Funds raised: 3',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Use the apiService to perform wallet actions
                    widget.apiService.testRegistration().then((isHealthy) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isHealthy
                              ? 'Server is running. Wallet management coming soon'
                              : 'Server is not responding. Please try again later'),
                        ),
                      );
                    });
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Feature Card Widget
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
      ),
    );
  }
}
