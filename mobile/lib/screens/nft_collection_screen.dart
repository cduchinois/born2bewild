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
  Map<String, dynamic>? _nftCollection;
  bool _isLoading = false;
  String? _errorMessage;
  final String _ownerAddress = 'bosq5LCREmQ4aiSwzYdvD7N1thoASZzHVqvCA1D2Cg5';

  @override
  void initState() {
    super.initState();
    _fetchNftCollection();
  }

  Future<void> _fetchNftCollection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Adapté pour utiliser le paramètre address défini dans la version mise à jour d'ApiService
      final nftCollection = await widget.apiService.fetchNftCollection(
        address: _ownerAddress,
      );
      setState(() {
        _nftCollection = nftCollection;
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
        title: const Text('KYA: Collection NFT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNftCollection,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _nftCollection != null
                  ? _buildCollectionView()
                  : const Center(child: Text('Aucune collection NFT trouvée')),
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
            'Erreur:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              _errorMessage ?? 'Une erreur inconnue est survenue',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchNftCollection,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // En-tête de la collection
        _buildCollectionHeader(),

        const Divider(height: 32),

        // Détails de la collection
        Text(
          'Détails de la collection',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        // Afficher les attributs organisés par catégories
        ..._buildOrganizedCollectionDetails(),
      ],
    );
  }

  Widget _buildCollectionHeader() {
    final name = _nftCollection?['name'] ?? 'Collection sans nom';
    final description =
        _nftCollection?['description'] ?? 'Aucune description disponible';
    final image = _nftCollection?['image'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Adresse du propriétaire
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet,
                  size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Propriétaire: ${_shortenAddress(_ownerAddress)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Image et titre
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la collection
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),

            const SizedBox(width: 16),

            // Titre et description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
    );
  }

  List<Widget> _buildOrganizedCollectionDetails() {
    if (_nftCollection == null) return [];

    final basicInfo = {
      'symbol': 'Symbole',
      'seller_fee_basis_points': 'Frais du vendeur',
      'external_url': 'URL externe',
    };

    final attributes = _nftCollection?['attributes'] as List<dynamic>? ?? [];

    List<Widget> widgets = [];

    // Information de base
    widgets.add(_buildCategorySection('Informations de base', basicInfo));

    // Attributs
    if (attributes.isNotEmpty) {
      widgets.add(const SizedBox(height: 20));
      widgets.add(
        Text(
          'Attributs',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );
      widgets.add(const SizedBox(height: 8));

      for (var attribute in attributes) {
        final traitType = attribute['trait_type'] ?? 'Non spécifié';
        final value = attribute['value']?.toString() ?? 'N/A';

        widgets.add(
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      traitType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(value),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Autres données
    final otherData = Map<String, dynamic>.from(_nftCollection!)
      ..removeWhere((key, value) =>
          basicInfo.containsKey(key) ||
          ['name', 'description', 'image', 'attributes'].contains(key));

    if (otherData.isNotEmpty) {
      widgets.add(const SizedBox(height: 20));
      widgets.add(
        Text(
          'Autres informations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );
      widgets.add(const SizedBox(height: 8));

      for (var entry in otherData.entries) {
        widgets.add(
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatValue(entry.value),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildCategorySection(String title, Map<String, String> fields) {
    List<Widget> items = [];

    items.add(
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
    items.add(const SizedBox(height: 8));

    for (var entry in fields.entries) {
      if (_nftCollection?.containsKey(entry.key) ?? false) {
        items.add(
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(_formatValue(_nftCollection![entry.key])),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
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
