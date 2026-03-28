class ListingModel {
  final String id;
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final int beds;
  final int baths;
  final bool isPremium;
  final String category;
  final double? latitude;
  final double? longitude;

  ListingModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.beds,
    required this.baths,
    this.isPremium = false,
    required this.category,
    this.latitude,
    this.longitude,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    // Backend stores coordinates as { type: 'Point', coordinates: [lng, lat] }
    final coords = json['coordinates']?['coordinates'];
    return ListingModel(
      id: (json['_id'] ?? json['id']) as String,
      title: json['title'] as String,
      location: json['location'] as String,
      price: json['price'] != null ? 'ETB ${json['price']}' : json['price'] as String,
      imageUrl: (json['images'] as List?)?.isNotEmpty == true
          ? json['images'][0] as String
          : json['imageUrl'] as String? ?? '',
      beds: (json['bedrooms'] ?? json['beds'] ?? 0) as int,
      baths: (json['bathrooms'] ?? json['baths'] ?? 0) as int,
      isPremium: json['isPremium'] as bool? ?? false,
      category: json['type'] as String? ?? json['category'] as String? ?? 'apartment',
      latitude: coords != null ? (coords[1] as num).toDouble() : null,
      longitude: coords != null ? (coords[0] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'price': price,
      'imageUrl': imageUrl,
      'beds': beds,
      'baths': baths,
      'isPremium': isPremium,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
