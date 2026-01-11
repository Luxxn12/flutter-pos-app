
class Product {
  final String id;
  final String name;
  final double priceLocal;
  final double priceForeign;
  final String? imageUrl;
  final String category;
  final int stock;
  final bool isActive;
  final bool trackStock;

  Product({
    required this.id, 
    required this.name, 
    required this.priceLocal,
    required this.priceForeign,
    this.imageUrl, 
    required this.category,
    this.stock = 0,
    this.isActive = true,
    this.trackStock = true,
  });
}
