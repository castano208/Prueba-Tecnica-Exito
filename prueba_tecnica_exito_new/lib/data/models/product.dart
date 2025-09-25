/// Modelo de datos para un producto
/// Representa la información de un producto en el sistema
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rate;
  final int count;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rate,
    required this.count,
  });

  /// Constructor factory para crear un Product desde JSON
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        title: json["title"],
        price: (json["price"] as num).toDouble(),
        description: json["description"],
        category: json["category"],
        image: json["image"],
        rate: (json["rating"]["rate"] as num).toDouble(),
        count: json["rating"]["count"],
      );

  /// Convierte el Product a un Map JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "description": description,
        "category": category,
        "image": image,
        "rating": {
          "rate": rate,
          "count": count,
        },
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, title: $title, price: $price)';
}
