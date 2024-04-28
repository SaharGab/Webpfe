class TouristSite {
  final String id;
  final String name;
  final String location;
  final String description;
  final List<String> imageUrls; // Il peut y avoir plusieurs images pour un site
  final String category; // Stocker l'ID de la catégorie, pas le titre

  TouristSite({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrls,
    required this.category,
  });

  // Convertir un TouristSite en Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'imageUrls': imageUrls,
      'categorySites': category,
    };
  }

  // Créer un TouristSite à partir d'une Map
  factory TouristSite.fromMap(Map<String, dynamic> map, String id) {
    return TouristSite(
      id: id,
      name: map['name'],
      location: map['location'],
      description: map['description'],
      imageUrls: List<String>.from(map['imageUrls']),
      category: map['categorySites'],
    );
  }
}
