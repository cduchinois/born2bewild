// lib/services/identity_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/credential.dart';

class IdentityService {
  final String baseUrl;

  IdentityService({required this.baseUrl});

  // Dans identity_service.dart
  Future<Map<String, dynamic>> createAnimalIdentity({
    required String name,
    required String species,
    required String birthDate,
    required String sanctuaryDid,
    Map<String, dynamic>? biometrics,
    Map<String, dynamic>? parents,
    String? subspecies,
    String? sex,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/identity/animal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'species': species,
          'birthDate': birthDate,
          'sanctuaryDid': sanctuaryDid,
          'subspecies': subspecies,
          'sex': sex,
          'biometrics': biometrics,
          'parents': parents,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body)['identity'];
      } else {
        throw Exception('Failed to create identity: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<VerifiableCredential> issueCredential({
    required String issuerDid,
    required String animalDid,
    required String credentialType,
    required Map<String, dynamic> credentialData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/identity/credential/issue'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'issuerDid': issuerDid,
        'animalDid': animalDid,
        'credentialType': credentialType,
        'credentialData': credentialData,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return VerifiableCredential.fromJson(responseData['credential']);
    } else {
      throw Exception('Failed to issue credential: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyCredential(
    VerifiableCredential credential,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/identity/credential/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'credential': credential.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify credential: ${response.body}');
    }
  }
}
