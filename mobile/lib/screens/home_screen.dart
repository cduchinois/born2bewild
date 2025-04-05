import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/nft_model.dart';
import '../widgets/nft_card.dart';
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
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<NFTModel> _nfts = [];
  final String _ownerAddress = 'bosq5LCREmQ4aiSwzYdvD7N1thoASZzHVqvCA1D2Cg5';

  @override
  void initState() {
    super.initState();
    _loadNFTs();
  }

  Future<void> _loadNFTs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final nfts = await widget.apiService.getNFTsByOwner(_ownerAddress);
      setState(() {
        _nfts = nfts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading NFTs: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Wallet Card
                _buildWalletCard(),

                const SizedBox(height: 20),

                // NFT Section
                _buildNFTSection(),

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
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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

  // Méthode pour construire la section NFT
  Widget _buildNFTSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Your Protected Animals',
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!_isLoading)
              TextButton.icon(
                onPressed: _loadNFTs,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // NFT Grid
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _nfts.isEmpty
                ? _buildEmptyNFTState()
                : _buildNFTGrid(),
      ],
    );
  }

  // Méthode pour construire la grille de NFTs
  Widget _buildNFTGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _nfts.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NFTCard(nft: _nfts[index]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Méthode pour construire l'état vide des NFTs
  Widget _buildEmptyNFTState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No protected animals found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanScreen(
                      apiService: widget.apiService,
                    ),
                  ),
                );
              },
              child: const Text('Scan an Animal'),
            ),
          ],
        ),
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
            Text(
              'Rain Forest Alliance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Address: ${widget.walletAddress}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$WILD Balance: 19.800',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Animals protected: ${_nfts.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Funds raised: 3',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
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
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          description,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }
}
