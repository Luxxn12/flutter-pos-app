import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/product.dart';
import '../supabase/supabase_providers.dart';

class ProductInput {
  final String name;
  final double priceLocal;
  final double priceForeign;
  final String category;
  final int stock;
  final String? imageUrl;
  final bool isActive;
  final bool trackStock;

  const ProductInput({
    required this.name,
    required this.priceLocal,
    required this.priceForeign,
    required this.category,
    required this.stock,
    this.imageUrl,
    required this.isActive,
    required this.trackStock,
  });

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'price_local': priceLocal,
      'price_foreign': priceForeign,
      'category': category,
      'stock': stock,
      'image_url': imageUrl,
      'is_active': isActive,
      'track_stock': trackStock,
    };
  }
}

class ProductRepository {
  ProductRepository(this._client);

  final SupabaseClient _client;

  Future<List<Product>> fetchProducts() async {
    final data = await _client
        .from('products')
        .select(
          'id,name,price_local,price_foreign,image_url,category,stock,is_active,track_stock',
        )
        .order('created_at');

    return data
        .map<Product>(
          (row) => Product(
            id: row['id'] as String,
            name: row['name'] as String,
            priceLocal: _toDouble(row['price_local']),
            priceForeign: _toDouble(row['price_foreign']),
            imageUrl: row['image_url'] as String?,
            category: row['category'] as String,
            stock: (row['stock'] as num?)?.toInt() ?? 0,
            isActive: row['is_active'] as bool? ?? true,
            trackStock: row['track_stock'] as bool? ?? true,
          ),
        )
        .toList();
  }

  Future<Product> createProduct(ProductInput input) async {
    final data = await _client
        .from('products')
        .insert(input.toInsertMap())
        .select(
          'id,name,price_local,price_foreign,image_url,category,stock,is_active,track_stock',
        )
        .single();

    return Product(
      id: data['id'] as String,
      name: data['name'] as String,
      priceLocal: _toDouble(data['price_local']),
      priceForeign: _toDouble(data['price_foreign']),
      imageUrl: data['image_url'] as String?,
      category: data['category'] as String,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isActive: data['is_active'] as bool? ?? true,
      trackStock: data['track_stock'] as bool? ?? true,
    );
  }

  Future<Product> updateProduct(String id, ProductInput input) async {
    final data = await _client
        .from('products')
        .update(input.toInsertMap())
        .eq('id', id)
        .select(
          'id,name,price_local,price_foreign,image_url,category,stock,is_active,track_stock',
        )
        .single();

    return Product(
      id: data['id'] as String,
      name: data['name'] as String,
      priceLocal: _toDouble(data['price_local']),
      priceForeign: _toDouble(data['price_foreign']),
      imageUrl: data['image_url'] as String?,
      category: data['category'] as String,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isActive: data['is_active'] as bool? ?? true,
      trackStock: data['track_stock'] as bool? ?? true,
    );
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<void> decrementStock(String productId, int quantity) async {
    final data = await _client
        .from('products')
        .select('stock,track_stock')
        .eq('id', productId)
        .maybeSingle();

    if (data == null) return;
    final trackStock = data['track_stock'] as bool? ?? false;
    if (!trackStock) return;

    final currentStock = (data['stock'] as num?)?.toInt() ?? 0;
    final updatedStock = (currentStock - quantity).clamp(0, 1 << 31);
    await _client
        .from('products')
        .update({'stock': updatedStock})
        .eq('id', productId);
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(supabaseClientProvider));
});

double _toDouble(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
