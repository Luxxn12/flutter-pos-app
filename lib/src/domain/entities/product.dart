
class Product {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String category;
  final int stock;

  Product({
    required this.id, 
    required this.name, 
    required this.price, 
    this.imageUrl, 
    required this.category,
    this.stock = 0,
  });
}
