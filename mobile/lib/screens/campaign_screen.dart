import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_campaign_screen.dart'; // Import the create campaign screen

class Campaign {
  final String title;
  final String description;
  final String imageUrl;
  final double fundingGoal;
  final double currentFunding;
  final int supporters;
  final String location;

  Campaign({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.fundingGoal,
    required this.currentFunding,
    required this.supporters,
    required this.location,
  });
}

class CampaignScreen extends StatefulWidget {
  final ApiService apiService;

  const CampaignScreen({super.key, required this.apiService});

  @override
  _CampaignScreenState createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final List<Campaign> _campaigns = [
    Campaign(
      title: 'Save the Bengal Tigers',
      description:
          'Help protect the endangered Bengal tigers in Ranthambore National Park. Your support provides anti-poaching patrols, habitat conservation, and medical care for injured tigers.',
      imageUrl: 'assets/images/tigre.jpg',
      fundingGoal: 50000,
      currentFunding: 25673,
      supporters: 324,
      location: 'Ranthambore, India',
    ),
    Campaign(
      title: 'Protecting Endangered Primates',
      description:
          'Preserve the habitat of endangered primates in the tropical forests. Support critical conservation efforts, research, and protection of these intelligent and vulnerable species.',
      imageUrl: 'assets/images/gorilla.jpg',
      fundingGoal: 100000,
      currentFunding: 62340,
      supporters: 789,
      location: 'Southeast Asian Rainforests',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Campaigns'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _campaigns.length,
        itemBuilder: (context, index) {
          final campaign = _campaigns[index];
          return _buildCampaignCard(campaign);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create campaign screen when '+' button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateCampaignScreen(
                apiService: widget.apiService,
                userType:
                    'AGREED_ASSOCIATION', // Setting as verified association
                // Pre-filled data can be passed here if needed
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    final progressPercentage =
        (campaign.currentFunding / campaign.fundingGoal) * 100;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campaign Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              campaign.imageUrl,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),

          // Campaign Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  campaign.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Location: ${campaign.location}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                // Funding Progress
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${campaign.currentFunding.toStringAsFixed(0)} raised',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Goal: \$${campaign.fundingGoal.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${campaign.supporters} supporters',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                // Donate Button
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Donation feature coming soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Donate Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
