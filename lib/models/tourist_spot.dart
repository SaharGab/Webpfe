class TouristSite {
  final String id;
  final String name;
  final String location;
  final String description;
  final List<String> imageUrls;
  final String category;
  final String? subcategory; // Optional field for subcategory

  TouristSite({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrls,
    required this.category,
    this.subcategory, // Subcategory is optional and depends on the category
  });

  /// Converts a TouristSite instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'imageUrls': imageUrls,
      'category': category,
      if (subcategory != null)
        'subcategory': subcategory, // Include subcategory if not null
    };
  }

  /// Creates a TouristSite instance from a map.
  factory TouristSite.fromMap(Map<String, dynamic> map, String id) {
    return TouristSite(
      id: id,
      name: map['name'] ?? 'N/A',
      location: map['location'] ?? 'Unknown location',
      description: map['description'] ?? 'No description provided',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      category: map['category'] ?? 'Uncategorized',
      subcategory: map['subcategory'], // This can be null if not present
    );
  }
}
