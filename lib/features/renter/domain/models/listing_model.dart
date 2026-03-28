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
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      price: json['price'] as String,
      imageUrl: json['imageUrl'] as String,
      beds: json['beds'] as int,
      baths: json['baths'] as int,
      isPremium: json['isPremium'] as bool? ?? false,
      category: json['category'] as String,
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
    };
  }
}
