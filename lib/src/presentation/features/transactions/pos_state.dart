
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/product_repository.dart';
import '../../../domain/entities/product.dart';

// --- Models ---


class CartItem {
  final String id;
  final Product product;
  final int quantity;

  CartItem({required this.id, required this.product, required this.quantity});

  double get total => product.priceLocal * quantity;
}

// --- Providers ---

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final repo = ref.read(productRepositoryProvider);
    return repo.fetchProducts();
  }

  Future<void> refresh() async {
    final repo = ref.read(productRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(repo.fetchProducts);
  }

  Future<Product> createProduct(ProductInput input) async {
    final repo = ref.read(productRepositoryProvider);
    final created = await repo.createProduct(input);
    state = state.whenData((items) => [created, ...items]);
    return created;
  }

  Future<Product> updateProduct(String id, ProductInput input) async {
    final repo = ref.read(productRepositoryProvider);
    final updated = await repo.updateProduct(id, input);
    state = state.whenData(
      (items) => items.map((p) => p.id == id ? updated : p).toList(),
    );
    return updated;
  }

  Future<void> deleteProduct(String id) async {
    final repo = ref.read(productRepositoryProvider);
    await repo.deleteProduct(id);
    state = state.whenData((items) => items.where((p) => p.id != id).toList());
  }
}

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

class SelectedCategoryIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final selectedCategoryIndexProvider =
    NotifierProvider<SelectedCategoryIndexNotifier, int>(
  SelectedCategoryIndexNotifier.new,
);

class ProductSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final productSearchQueryProvider =
    NotifierProvider<ProductSearchQueryNotifier, String>(
  ProductSearchQueryNotifier.new,
);

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
