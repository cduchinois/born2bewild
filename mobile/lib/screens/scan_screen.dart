import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  final ApiService apiService;

  const ScanScreen({super.key, required this.apiService});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isProcessing = false;
  bool _scanComplete = false;

  // Simulation data
  final Map<String, dynamic> _animalData = {
    'name': 'Toby',
    'species': 'Gorilla',
    'age': '4 years',
    'gender': 'Female',
    'location': 'Ranthambore National Park, India',
    'status': 'Protected',
    'lastScan': 'April 5, 2025'
  };

  @override
  void initState() {
    super.initState();
    // Force iOS to initialize camera permission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCameraPermission();
    });
  }

  Future<void> _checkCameraPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.camera.status;
      print('Initial camera permission status: $status');

      // Si le statut est non déterminé, on force une demande
      if (status == PermissionStatus.denied) {
        final result = await Permission.camera.request();
        print('Permission request result: $result');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Scanner'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top info
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.pets, size: 48, color: Colors.green),
                      SizedBox(height: 12),
                      Text(
                        'Wildlife Recognition',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Take a clear photo of an animal to identify it and contribute to conservation efforts',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Camera preview or image display
              if (_imageFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _imageFile!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Camera button
              if (!_scanComplete)
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label:
                      Text(_imageFile == null ? 'Take Photo' : 'Retake Photo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

              // Loading indicator
              if (_isProcessing) ...[
                const SizedBox(height: 20),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Analyzing image...'),
                    ],
                  ),
                ),
              ],

              // Results
              if (_scanComplete) ...[
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Animal Identified!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('Name', _animalData['name']),
                        _buildInfoRow('Species', _animalData['species']),
                        _buildInfoRow('Age', _animalData['age']),
                        _buildInfoRow('Gender', _animalData['gender']),
                        _buildInfoRow('Location', _animalData['location']),
                        _buildInfoRow('Status', _animalData['status']),
                        _buildInfoRow('Last Scan', _animalData['lastScan']),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Details coming soon')),
                                    );
                                  },
                                  icon:
                                      const Icon(Icons.info_outline, size: 18),
                                  label: const Text('Details',
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Observation recorded')),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_note, size: 18),
                                  label: const Text('Observation',
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Scan again button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _scanComplete = false;
                      _imageFile = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Scan Another Animal',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePicture() async {
    // Pour les tests, on peut utiliser cette variable pour simuler au lieu d'utiliser la vraie caméra
    final bool simulateCamera = false;

    if (!simulateCamera) {
      try {
        // Vérifier les permissions sur iOS
        if (Platform.isIOS) {
          final status = await Permission.camera.request();
          if (status.isDenied) {
            if (context.mounted) {
              _showPermissionDialog();
            }
            return;
          }
        }

        setState(() {
          _isProcessing = true;
        });

        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 80,
        );

        if (image == null) {
          setState(() {
            _isProcessing = false;
          });
          return; // L'utilisateur a annulé
        }

        setState(() {
          _imageFile = File(image.path);
        });

        // Simuler un délai d'analyse
        await Future.delayed(const Duration(seconds: 2));

        // Simuler un résultat réussi
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _scanComplete = true;
          });
        }
      } catch (e) {
        print('Erreur de caméra: $e');
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    } else {
      // Mode simulation (pour les tests sans caméra)
      setState(() {
        _isProcessing = true;
      });

      // Simuler un délai
      await Future.delayed(const Duration(seconds: 2));

      // Simuler un résultat réussi sans image réelle
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _scanComplete = true;
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission requise'),
          content: const Text(
            'L\'accès à la caméra est nécessaire pour scanner les animaux. '
            'Veuillez autoriser l\'accès dans les paramètres de votre appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Paramètres'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value ?? 'Inconnu'),
          ),
        ],
      ),
    );
  }
}
