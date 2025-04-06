import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/nft_model.dart';

class NFTDetailScreen extends StatelessWidget {
  final NFTModel nft;

  const NFTDetailScreen({Key? key, required this.nft}) : super(key: key);

  // Méthode pour ouvrir Solscan
  Future<void> _launchSolscan() async {
    // URL de base pour Solscan Devnet
    // final solscanUrl = 'https://solscan.io/token/${nft.chipId}?cluster=devnet';
    const solscanUrl =
        'https://solscan.io/account/bosq5LCREmQ4aiSwzYdvD7N1thoASZzHVqvCA1D2Cg5?cluster=devnet';

    try {
      final Uri url = Uri.parse(solscanUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $solscanUrl');
      }
    } catch (e) {
      print('Error launching Solscan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nft.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                nft.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    ),
                  );
                },
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton Solscan
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _launchSolscan,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('View on Solscan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow('Name', nft.name),
                  _buildDetailRow('Description', nft.description),
                  _buildDetailRow('Status', nft.status),
                  _buildDetailRow('Chip ID', nft.chipId),

                  const SizedBox(height: 16),
                  Text(
                    'Attributes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...nft.attributes
                      .map(
                          (attr) => _buildDetailRow(attr.traitType, attr.value))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
