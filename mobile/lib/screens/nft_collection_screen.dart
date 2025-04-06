import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class NftCollectionScreen extends StatefulWidget {
  final ApiService apiService;

  const NftCollectionScreen({Key? key, required this.apiService})
      : super(key: key);

  @override
  _NftCollectionScreenState createState() => _NftCollectionScreenState();
}

class _NftCollectionScreenState extends State<NftCollectionScreen> {
  // Data management
  Map<String, dynamic>? _collectionData;
  List<Map<String, dynamic>> _collectionAssets = [];

  // State management
  bool _isLoading = true;
  String? _errorMessage;

  // Fixed owner address
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
      // Fetch collection metadata and assets concurrently
      final results = await Future.wait([
        widget.apiService.fetchNftCollection(address: _ownerAddress),
        widget.apiService.fetchNftCollectionAssets(address: _ownerAddress),
      ]);

      setState(() {
        _collectionData = results[0];
        _collectionAssets =
            List<Map<String, dynamic>>.from(results[1]['assets'] ?? []);
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
        title: Text(_collectionData?['name'] ?? 'NFT Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCollectionData,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildCollectionDetails() {
    if (_collectionData == null) return const SizedBox.shrink();

    final detailsToShow = {
      'symbol': 'Symbol',
      'seller_fee_basis_points': 'Seller Fee',
      'external_url': 'External URL',
    };

    final details = detailsToShow.entries
        .where((entry) => _collectionData?[entry.key] != null)
        .map((entry) {
      final value = _collectionData?[entry.key];
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(entry.value),
          subtitle: Text(_formatValue(value)),
        ),
      );
    }).toList();

    if (details.isEmpty) return const SizedBox.shrink();

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
          ...details,
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is List) return value.join(', ');
    if (value is Map) return json.encode(value);
    return value.toString();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorView();
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
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 64),
          const SizedBox(height: 16),
          Text('Error', style: Theme.of(context).textTheme.titleLarge),
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
          Chip(
            avatar: const Icon(Icons.account_balance_wallet, size: 16),
            label: Text(_shortenAddress(_ownerAddress)),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCollectionImage(image),
              const SizedBox(width: 16),
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
      return _buildPlaceholderImage(120, 120);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderImage(120, 120),
      ),
    );
  }

  Widget _buildPlaceholderImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildAssetsSection() {
    if (_collectionAssets.isEmpty) {
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
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _collectionAssets.length,
            itemBuilder: (context, index) {
              final asset = _collectionAssets[index];
              return _buildAssetCard(asset);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    return GestureDetector(
      onTap: () => _showAssetDetailsDialog(asset),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  asset['image'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              asset['name'] ?? 'Unnamed Asset',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (asset['description'] != null && asset['description'].isNotEmpty)
              Text(
                asset['description'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  void _showAssetDetailsDialog(Map<String, dynamic> asset) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                width: constraints.maxWidth * 0.9,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button and title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            asset['name'] ?? 'Asset Details',
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),

                    // Asset Image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          asset['image'] ?? '',
                          width: constraints.maxWidth * 0.7,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: constraints.maxWidth * 0.7,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),

                    // Description
                    if (asset['description'] != null &&
                        asset['description'].isNotEmpty)
                      _buildSectionHeader('Description'),
                    if (asset['description'] != null &&
                        asset['description'].isNotEmpty)
                      Text(
                        asset['description'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                    // Attributes
                    if (asset['attributes'] != null &&
                        (asset['attributes'] as List).isNotEmpty)
                      _buildSectionHeader('Attributes'),
                    if (asset['attributes'] != null &&
                        (asset['attributes'] as List).isNotEmpty)
                      ..._buildAttributeWidgets(asset['attributes']),

                    // External URL
                    if (asset['external_url'] != null)
                      _buildSectionHeader('External URL'),
                    if (asset['external_url'] != null)
                      Text(
                        asset['external_url'],
                        style: const TextStyle(color: Colors.blue),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  List<Widget> _buildAttributeWidgets(List attributes) {
    return attributes.map<Widget>((attr) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(
            attr['trait_type'] ?? '',
            style: const TextStyle(color: Colors.black87),
          ),
          trailing: Text(
            attr['value'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    }).toList();
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}
