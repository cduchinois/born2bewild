// lib/models/primate.dart
class Primate {
  final String id;
  final String name;
  final String species;
  final int age;
  final String did;
  final String imageUrl;
  final Map<String, dynamic> metadata;

  Primate({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.did,
    required this.imageUrl,
    this.metadata = const {},
  });

  factory Primate.fromJson(Map<String, dynamic> json) {
    return Primate(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      age: json['age'],
      did: json['did'],
      imageUrl: json['imageUrl'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'age': age,
      'did': did,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }
}

// lib/models/did_credential.dart
class DIDCredential {
  final String did;
  final String issuer;
  final DateTime issuanceDate;
  final Map<String, dynamic> claims;

  DIDCredential({
    required this.did,
    required this.issuer,
    required this.issuanceDate,
    required this.claims,
  });

  factory DIDCredential.fromJson(Map<String, dynamic> json) {
    return DIDCredential(
      did: json['did'],
      issuer: json['issuer'],
      issuanceDate: DateTime.parse(json['issuanceDate']),
      claims: json['claims'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'did': did,
      'issuer': issuer,
      'issuanceDate': issuanceDate.toIso8601String(),
      'claims': claims,
    };
  }
}
