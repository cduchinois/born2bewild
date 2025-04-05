// lib/models/credential.dart
class VerifiableCredential {
  final String id;
  final List<String> type;
  final String issuer;
  final String issuanceDate;
  final String expirationDate;
  final CredentialSubject credentialSubject;
  final CredentialProof? proof;

  VerifiableCredential({
    required this.id,
    required this.type,
    required this.issuer,
    required this.issuanceDate,
    required this.expirationDate,
    required this.credentialSubject,
    this.proof,
  });

  factory VerifiableCredential.fromJson(Map<String, dynamic> json) {
    return VerifiableCredential(
      id: json['id'],
      type: List<String>.from(json['type']),
      issuer: json['issuer'],
      issuanceDate: json['issuanceDate'],
      expirationDate: json['expirationDate'],
      credentialSubject: CredentialSubject.fromJson(json['credentialSubject']),
      proof: json['proof'] != null
          ? CredentialProof.fromJson(json['proof'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '@context': [
          'https://www.w3.org/2018/credentials/v1',
          'https://schema.privado.io/credentials/animal/v1'
        ],
        'id': id,
        'type': type,
        'issuer': issuer,
        'issuanceDate': issuanceDate,
        'expirationDate': expirationDate,
        'credentialSubject': credentialSubject.toJson(),
        if (proof != null) 'proof': proof!.toJson(),
      };
}

class CredentialSubject {
  final String id;
  final String examination;
  final String date;
  final String status;
  final String weight;
  final String nextCheckup;
  final Veterinarian veterinarian;

  CredentialSubject({
    required this.id,
    required this.examination,
    required this.date,
    required this.status,
    required this.weight,
    required this.nextCheckup,
    required this.veterinarian,
  });

  factory CredentialSubject.fromJson(Map<String, dynamic> json) {
    return CredentialSubject(
      id: json['id'],
      examination: json['examination'],
      date: json['date'],
      status: json['status'],
      weight: json['weight'],
      nextCheckup: json['nextCheckup'],
      veterinarian: Veterinarian.fromJson(json['veterinarian']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'examination': examination,
        'date': date,
        'status': status,
        'weight': weight,
        'nextCheckup': nextCheckup,
        'veterinarian': veterinarian.toJson(),
      };
}

class Veterinarian {
  final String name;
  final String license;

  Veterinarian({
    required this.name,
    required this.license,
  });

  factory Veterinarian.fromJson(Map<String, dynamic> json) {
    return Veterinarian(
      name: json['name'],
      license: json['license'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'license': license,
      };
}

class CredentialProof {
  final String type;
  final String created;
  final BlockchainRef blockchainRef;

  CredentialProof({
    required this.type,
    required this.created,
    required this.blockchainRef,
  });

  factory CredentialProof.fromJson(Map<String, dynamic> json) {
    return CredentialProof(
      type: json['type'],
      created: json['created'],
      blockchainRef: BlockchainRef.fromJson(json['blockchainRef']),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'created': created,
        'blockchainRef': blockchainRef.toJson(),
      };
}

class BlockchainRef {
  final int chainId;
  final String transactionHash;
  final int blockNumber;

  BlockchainRef({
    required this.chainId,
    required this.transactionHash,
    required this.blockNumber,
  });

  factory BlockchainRef.fromJson(Map<String, dynamic> json) {
    return BlockchainRef(
      chainId: json['chainId'],
      transactionHash: json['transactionHash'],
      blockNumber: json['blockNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
        'chainId': chainId,
        'transactionHash': transactionHash,
        'blockNumber': blockNumber,
      };
}
