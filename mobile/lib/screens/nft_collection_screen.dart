import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class NftCollectionScreen extends StatefulWidget {
  final ApiService apiService;

  const NftCollectionScreen({super.key, required this.apiService});

  @override
  _NftCollectionScreenState createState() => _NftCollectionScreenState();
}

class _NftCollectionScreenState extends State<NftCollectionScreen> {
  // Collection data
  Map<String, dynamic>? _collectionData;
  List<dynamic>? _collectionAssets;

  // State management
  bool _isLoading = true;
  String? _errorMessage;

  // Fixed owner address (consider making this dynamic if needed)
  final String _ownerAddress = '8AbQVR7qVsSbMTCWoAkADqwGBg2UGHEwnngqav69HS1t';

  @override
  void initState() {
    super.initState();
    _fetchCollectionData();
  }

  Future<void> _fetchCollectionData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch collection metadata
      final collectionMetadata = await widget.apiService.fetchNftCollection(
        address: _ownerAddress,
      );

      // Fetch collection assets
      final collectionAssetsResponse =
          await widget.apiService.fetchNftCollectionAssets(
        address: _ownerAddress,
      );

      setState(() {
        _collectionData = collectionMetadata;
        _collectionAssets = collectionAssetsResponse['assets'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFT Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCollectionData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_collectionData == null) {
      return const Center(child: Text('No collection found'));
    }

    return RefreshIndicator(
      onRefresh: _fetchCollectionData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildCollectionHeader()),
          SliverToBoxAdapter(child: _buildAssetsSection()),
          SliverToBoxAdapter(child: _buildCollectionDetails()),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchCollectionData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionHeader() {
    final name = _collectionData?['name'] ?? 'Unnamed Collection';
    final description = _collectionData?['description'] ?? 'No description';
    final image = _collectionData?['image'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Owner Address Chip
          Chip(
            avatar: const Icon(Icons.account_balance_wallet, size: 16),
            label: Text(_shortenAddress(_ownerAddress)),
          ),
          const SizedBox(height: 16),

          // Collection Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Collection Image
              _buildCollectionImage(image),
              const SizedBox(width: 16),

              // Collection Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionImage(String? imageUrl) {
    if (imageUrl == null) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildAssetsSection() {
    if (_collectionAssets == null || _collectionAssets!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No assets in this collection'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Collection Assets',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _collectionAssets!.length,
            itemBuilder: (context, index) {
              final asset = _collectionAssets![index];
              return _buildAssetCard(asset);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              asset['image'] ?? '', // Now directly using 'image'
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            asset['name'] ?? 'Unnamed Asset', // Using 'name'
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionDetails() {
    if (_collectionData == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collection Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ..._buildDetailCards(),
        ],
      ),
    );
  }

  List<Widget> _buildDetailCards() {
    final detailsToShow = {
      'symbol': 'Symbol',
      'seller_fee_basis_points': 'Seller Fee',
      'external_url': 'External URL',
    };

    return detailsToShow.entries.map((entry) {
      final value = _collectionData?[entry.key];
      if (value == null) return const SizedBox.shrink();

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(entry.value),
          subtitle: Text(_formatValue(value)),
        ),
      );
    }).toList();
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is List) return value.join(', ');
    if (value is Map) return json.encode(value);
    return value.toString();
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}
