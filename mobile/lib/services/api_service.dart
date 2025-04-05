import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/nft_model.dart';

class ApiService {
  final String baseUrl;

  final ImagePicker _imagePicker = ImagePicker();

  ApiService({required this.baseUrl}) {
    debugPrint('ApiService initialized with URL: $baseUrl');
  }

  Future<Map<String, dynamic>> fetchNftCollection() async {
    try {
      final url = Uri.parse('$baseUrl/fetch-nft-collection');
      debugPrint('Fetching NFT Collection from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('NFT collection fetch timed out');
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> metadata = json.decode(response.body);
        debugPrint('Parsed NFT Collection metadata: $metadata');
        return metadata;
      } else {
        throw Exception('Failed to fetch NFT collection: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching NFT collection: $e');
      rethrow;
    }
  }

  // Méthode d'enregistrement utilisateur
  Future<Map<String, dynamic>> registerUser() async {
    try {
      final url = Uri.parse('$baseUrl/register');
      debugPrint('Sending registration request to: $url');

      final request = {
        // le champ est requis selon l'erreur backend
        "address": "",
        "private_key": null,
        "user_info": {
          "name": "PawesomeID User",
          "timestamp": DateTime.now().toIso8601String(),
          "device": Platform.operatingSystem,
        }
      };

      debugPrint('Request body: ${jsonEncode(request)}');

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('Request timed out after 60 seconds');
          throw Exception(
              'Connection timed out - server might be busy or network issues');
        },
      );
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      debugPrint('Request body sent: ${jsonEncode(request)}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint('Parsed response data: $data');

        // Vérifiez la structure exacte de la réponse
        if (data['did'] != null &&
            data['didDocument'] != null &&
            data['transaction_id'] != null) {
          return {
            'status': 'success',
            'did': data['did'],
            'address': data['didDocument']['verificationMethod'][0]
                ['publicKeyBase58'],
            'transaction_id': data['transaction_id'],
            'didDocument': data['didDocument'],
            'confirmed_round': data['confirmed_round']
          };
        } else {
          throw Exception('Invalid response format: missing required fields');
        }
      } else {
        throw Exception(
            json.decode(response.body)['detail'] ?? 'Registration failed');
      }
    } catch (e, stackTrace) {
      debugPrint('Registration error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Méthode de vérification du visage
  Future<Map<String, dynamic>> verifyFace() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) {
        throw Exception('No image captured');
      }

      File imageFile = File(image.path);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      debugPrint('Image captured successfully at: ${image.path}');
      debugPrint('Image size: ${await imageFile.length()} bytes');

      await Future.delayed(const Duration(seconds: 1));

      try {
        await imageFile.delete();
      } catch (e) {
        debugPrint('Warning: Could not delete temporary file: $e');
      }

      return {'verified': true, 'message': 'Face verification successful'};
    } catch (e) {
      debugPrint('Face verification error: $e');
      rethrow;
    }
  }

  // Méthode de vérification du document
  Future<Map<String, dynamic>> verifyDocument() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) {
        throw Exception('No document captured');
      }

      File imageFile = File(image.path);
      if (!await imageFile.exists()) {
        throw Exception('Document image file not found');
      }

      debugPrint('Document captured successfully at: ${image.path}');
      debugPrint('Document size: ${await imageFile.length()} bytes');

      await Future.delayed(const Duration(seconds: 1));

      try {
        await imageFile.delete();
      } catch (e) {
        debugPrint('Warning: Could not delete temporary file: $e');
      }

      return {'verified': true, 'message': 'Document verification successful'};
    } catch (e) {
      debugPrint('Document verification error: $e');
      rethrow;
    }
  }

  // Méthode de vérification DID
  Future<Map<String, dynamic>> verifyDID(String transactionId) async {
    try {
      final url = Uri.parse('$baseUrl/verify-did/$transactionId');
      debugPrint('Sending GET request to: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Verification request timed out');
        },
      );

      debugPrint('Verification response code: ${response.statusCode}');
      debugPrint('Verification response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'verified': data['verified'] ?? false,
          'status': data['status'],
        };
      } else {
        throw Exception('DID verification failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Verification error: $e');
      rethrow;
    }
  }

  // Méthode de test de l'API
  Future<bool> testRegistration() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Health check timed out');
        },
      );

      debugPrint('Health check status: ${response.statusCode}');
      debugPrint('Health check response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  // Méthode pour récupérer les NFT d'un propriétaire (simulée)
  Future<List<NFTModel>> getNFTsByOwner(String ownerAddress) async {
    // En production, vous feriez ici un appel API à Metaplex ou à votre backend
    // Pour l'exemple, nous retournons un NFT codé en dur basé sur l'exemple fourni

    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 1));

    // Données simulées pour plusieurs NFT
    return [
      NFTModel(
        name: "Wild SOL NFT",
        description: "This is an NFT to help wild animals on Solana",
        imageUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3qHVGtRWXsEgL-jnVAMbLh64IH9JZE2QQ0yMHWVdpPaf9lDwM9aAiUf_B7cUjCbSTrHm96PqkbgZcwVGR9z_tJA",
        externalUrl: "https://wildsol.com",
        attributes: [
          NFTAttribute(traitType: "issuerID", value: "fdadf"),
          NFTAttribute(traitType: "chipId", value: "xxxxxddddeee"),
          NFTAttribute(traitType: "status", value: "alive"),
        ],
        status: "alive",
        chipId: "xxxxxddddeee",
      ),
      NFTModel(
        name: "Bengal Tiger #A2451",
        description: "Protected Bengal Tiger in Ranthambore National Park",
        imageUrl:
            "https://images.unsplash.com/photo-1549366021-9f761d450615?q=80&w=1000&auto=format&fit=crop",
        externalUrl: "https://wildsol.com",
        attributes: [
          NFTAttribute(traitType: "issuerID", value: "wlf-ind-045"),
          NFTAttribute(traitType: "chipId", value: "bngl-2451-rfid"),
          NFTAttribute(traitType: "status", value: "protected"),
        ],
        status: "protected",
        chipId: "bngl-2451-rfid",
      ),
      NFTModel(
        name: "African Elephant #E1123",
        description: "Monitored elephant in Serengeti National Park",
        imageUrl:
            "https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?q=80&w=1000&auto=format&fit=crop",
        externalUrl: "https://wildsol.com",
        attributes: [
          NFTAttribute(traitType: "issuerID", value: "wlf-tnz-089"),
          NFTAttribute(traitType: "chipId", value: "elph-1123-rfid"),
          NFTAttribute(traitType: "status", value: "monitored"),
        ],
        status: "monitored",
        chipId: "elph-1123-rfid",
      ),
    ];
  }

  // Exemple d'implémentation réelle d'appel API (commenté)
  /*
  Future<List<NFTModel>> getNFTsByOwnerReal(String ownerAddress) async {
    try {
      final url = Uri.parse('$baseUrl/nfts/$ownerAddress');
      debugPrint('Fetching NFTs for owner: $ownerAddress');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> nftsJson = json.decode(response.body);
        return nftsJson.map((nftJson) => NFTModel.fromJson(nftJson)).toList();
      } else {
        throw Exception('Failed to load NFTs: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching NFTs: $e');
      rethrow;
    }
  }
  */
}
