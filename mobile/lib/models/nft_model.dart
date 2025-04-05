class NFTAttribute {
  final String traitType;
  final String value;

  NFTAttribute({
    required this.traitType,
    required this.value,
  });

  factory NFTAttribute.fromJson(Map<String, dynamic> json) {
    return NFTAttribute(
      traitType: json['trait_type'] ?? json['traitType'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trait_type': traitType,
      'value': value,
    };
  }
}

class NFTModel {
  final String name;
  final String description;
  final String imageUrl;
  final String externalUrl;
  final List<NFTAttribute> attributes;
  final String status;
  final String chipId;

  NFTModel({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.externalUrl,
    required this.attributes,
    required this.status,
    required this.chipId,
  });

  factory NFTModel.fromJson(Map<String, dynamic> json) {
    List<NFTAttribute> attributesList = [];
    if (json['attributes'] != null) {
      attributesList = List<NFTAttribute>.from(
        json['attributes'].map((attr) => NFTAttribute.fromJson(attr)),
      );
    }

    // Extraire le statut et le chipId des attributs pour un accès plus facile
    String status = '';
    String chipId = '';
    for (var attr in attributesList) {
      if (attr.traitType == 'status') {
        status = attr.value;
      } else if (attr.traitType == 'chipId') {
        chipId = attr.value;
      }
    }

    return NFTModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      externalUrl: json['external_url'] ?? json['externalUrl'] ?? '',
      attributes: attributesList,
      status: status,
      chipId: chipId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': imageUrl,
      'external_url': externalUrl,
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
    };
  }
}
