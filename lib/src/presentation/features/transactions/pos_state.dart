
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/product.dart';

// --- Models ---


class CartItem {
  final String id;
  final Product product;
  final int quantity;

  CartItem({required this.id, required this.product, required this.quantity});

  double get total => product.price * quantity;
}

// --- Providers ---

// Mock Products
final productsProvider = Provider<List<Product>>((ref) {
  return [
    Product(id: '1', name: 'Kopi Susu', price: 18000, category: 'Minuman', stock: 145),
    Product(id: '2', name: 'Teh Tarik', price: 15000, category: 'Minuman', stock: 52),
    Product(id: '3', name: 'Nasi Goreng', price: 25000, category: 'Makanan', stock: 21),
    Product(id: '4', name: 'Mie Goreng', price: 25000, category: 'Makanan', stock: 12),
    Product(id: '5', name: 'Roti Bakar', price: 12000, category: 'Snack', stock: 4),
    Product(id: '6', name: 'Pisang Goreng', price: 10000, category: 'Snack', stock: 0),
    Product(id: '7', name: 'Es Jeruk', price: 10000, category: 'Minuman', stock: 88),
    Product(id: '8', name: 'Air Mineral', price: 5000, category: 'Minuman', stock: 210),
  ];
});

// Cart State Logic
// Cart State Logic
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addProduct(Product product) {
    final existingItemIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex >= 0) {
      // Create new list with updated item
      final updatedList = [...state];
      final existingItem = updatedList[existingItemIndex];
      updatedList[existingItemIndex] = CartItem(
        id: existingItem.id, // Keep existing CartItem ID (which is distinct from Product ID, but here likely we want to track by Product ID for aggregation)
        product: existingItem.product,
        quantity: existingItem.quantity + 1,
      );
      state = updatedList;
    } else {
      state = [
        ...state,
        CartItem(id: const Uuid().v4(), product: product, quantity: 1),
      ];
    }
  }

  void removeProduct(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }
  
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeProduct(itemId);
      return;
    }
    state = state.map((item) {
      if (item.id == itemId) {
        return CartItem(id: item.id, product: item.product, quantity: quantity);
      }
      return item;
    }).toList();
  }

  void clear() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.total);
});
