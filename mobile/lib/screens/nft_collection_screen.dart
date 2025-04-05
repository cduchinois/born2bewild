import 'package:flutter/material.dart';
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
      final nftCollection = await widget.apiService.fetchNftCollection();
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
        title: const Text('NFT Collection'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_errorMessage'),
                      ElevatedButton(
                        onPressed: _fetchNftCollection,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _nftCollection != null
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          'NFT Collection Details',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        ..._buildCollectionDetails(),
                      ],
                    )
                  : const Center(child: Text('No NFT collection found')),
    );
  }

  List<Widget> _buildCollectionDetails() {
    if (_nftCollection == null) return [];

    return [
      for (var entry in _nftCollection!.entries)
        ListTile(
          title: Text(
            entry.key.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(entry.value?.toString() ?? 'N/A'),
        ),
    ];
  }
}
