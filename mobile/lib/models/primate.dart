class Primate {
  final String id;
  final String name;
  final String species;
  final int age;
  final String did;
  final String imageUrl;
  final String sanctuary;
  final Map<String, dynamic> metadata;

  Primate({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.did,
    required this.imageUrl,
    required this.sanctuary,
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
      sanctuary: json['sanctuary'],
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
      'sanctuary': sanctuary,
      'metadata': metadata,
    };
  }
}
