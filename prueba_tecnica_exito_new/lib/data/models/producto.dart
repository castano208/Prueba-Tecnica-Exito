class Producto {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rate;
  final int count;

  Producto({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rate,
    required this.count,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json["id"],
        title: json["title"],
        price: (json["price"] as num).toDouble(),
        description: json["description"],
        category: json["category"],
        image: json["image"],
        rate: (json["rating"]["rate"] as num).toDouble(),
        count: json["rating"]["count"],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Producto && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
