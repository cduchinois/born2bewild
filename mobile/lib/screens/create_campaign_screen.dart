import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class CreateCampaignScreen extends StatefulWidget {
  final ApiService apiService;
  final String userType;

  const CreateCampaignScreen({
    Key? key,
    required this.apiService,
    required this.userType,
  }) : super(key: key);

  @override
  _CreateCampaignScreenState createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();

  // Pre-filled form controllers for monkey nursery example
  final TextEditingController _titleController = TextEditingController(
    text: "Save the Primate Orphan Nursery",
  );

  final TextEditingController _descriptionController = TextEditingController(
    text:
        "Our urgent initiative aims to rescue and rehabilitate orphaned baby monkeys in the Central African Rainforest region. These vulnerable infants have lost their mothers to poaching and habitat destruction, and face certain death without specialized care.\n\n"
        "The nursery currently houses 28 infant primates of various endangered species including:\n"
        "• Golden Snub-nosed Monkeys\n"
        "• Black Crested Mangabeys\n"
        "• Red-tailed Guenons\n"
        "• Endangered Allen's Swamp Monkeys\n\n"
        "Your donation will support:\n"
        "• 24/7 specialized care by trained wildlife professionals\n"
        "• Species-appropriate nutrition and formula for orphaned infants\n"
        "• Veterinary care and medical supplies\n"
        "• Improved nursery facilities and natural enrichment\n"
        "• Anti-poaching initiatives to protect remaining wild populations\n\n"
        "With your help, we can give these orphaned primates a second chance at life and contribute to the conservation of endangered species. Each rescued infant represents hope for their vulnerable species.",
  );

  final TextEditingController _walletAddressController = TextEditingController(
    text: "8xGT7AxSAfD2AHVuUHPCFDM4dPwPVrBJqJTAkzBnVzQN",
  );

  final TextEditingController _fundingGoalController = TextEditingController(
    text: "25",
  );

  final TextEditingController _locationController = TextEditingController(
    text: "Central African Rainforest, Congo Basin",
  );

  bool _isAgreedAssociation = false;
  bool _isVerifiedAssociation = false;
  String _selectedImagePath = 'assets/images/monkey_nursery.jpg';

  @override
  void initState() {
    super.initState();
    // Check if user is an agreed association
    _checkAssociationStatus();
  }

  void _checkAssociationStatus() {
    setState(() {
      // Set to true for this example to show the full form
      _isAgreedAssociation = widget.userType == 'AGREED_ASSOCIATION';
      _isVerifiedAssociation = _isAgreedAssociation;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAgreedAssociation) {
      return Scaffold(
        appBar: AppBar(title: const Text('Campaign Creation')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 100, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  'Campaign Creation is Limited to Verified Associations',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to association verification process
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Association Verification Process')),
                    );
                  },
                  child: const Text('Verify Association'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Wildlife Campaign'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campaign Image Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campaign Image',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(Icons.photo_library,
                              size: 80, color: Colors.grey[400]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // In a real app, this would open an image picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Image selection would open here')),
                          );
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Image'),
                      ),
                    ],
                  ),
                ),
              ),

              // Solana Wallet Integration
              const SizedBox(height: 16),
              TextFormField(
                controller: _walletAddressController,
                decoration: InputDecoration(
                  labelText: 'Solana Wallet Address',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: _walletAddressController.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wallet Address Copied')),
                      );
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Solana wallet address';
                  }
                  // Basic Solana address validation
                  if (value.length < 32 || value.length > 44) {
                    return 'Invalid Solana wallet address';
                  }
                  return null;
                },
              ),

              // Campaign Details
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Campaign Title',
                  hintText: 'A clear, impactful title',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Campaign Location',
                  hintText: 'Where is this conservation project located?',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Location is required' : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Campaign Description',
                  hintText: 'Detailed description of your conservation effort',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Description is required' : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _fundingGoalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Funding Goal (SOL)',
                  hintText: 'Amount of SOL you aim to raise',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Funding goal is required';
                  }
                  final goal = double.tryParse(value);
                  if (goal == null || goal <= 0) {
                    return 'Please enter a valid SOL amount';
                  }
                  if (goal < 10) {
                    return 'Minimum campaign goal is 10 SOL';
                  }
                  return null;
                },
              ),

              // SOL Payment Confirmation
              const SizedBox(height: 24),
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💸 SOL Campaign Launch Fee',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Campaign Creation Requirements:\n'
                        '• 1 SOL Launch Fee\n'
                        '• Minimum Campaign Goal: 10 SOL\n'
                        '• Fees support platform maintenance and conservation efforts',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),

              // Submit Button
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitCampaign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Launch Campaign on Solana',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitCampaign() {
    if (_formKey.currentState!.validate()) {
      // Show success message with campaign details
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Campaign Submission Successful!'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Campaign: ${_titleController.text}'),
                  const SizedBox(height: 8),
                  Text('Location: ${_locationController.text}'),
                  const SizedBox(height: 8),
                  Text('Funding Goal: ${_fundingGoalController.text} SOL'),
                  const SizedBox(height: 16),
                  const Text(
                      'Your campaign has been submitted to the blockchain and will be live shortly!'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to campaign list
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }
}
