import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/product.dart';
import '../categories/categories_provider.dart';
import '../transactions/pos_state.dart'; // Importing provider from POS for now
import '../auth/auth_provider.dart';

class SelectedProductCategoryIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final selectedProductCategoryIndexProvider =
    NotifierProvider<SelectedProductCategoryIndexNotifier, int>(
  SelectedProductCategoryIndexNotifier.new,
);

class ProductListSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final productListSearchQueryProvider =
    NotifierProvider<ProductListSearchQueryNotifier, String>(
  ProductListSearchQueryNotifier.new,
);

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final searchQuery = ref.watch(productListSearchQueryProvider);
    final selectedCategoryIndex =
        ref.watch(selectedProductCategoryIndexProvider);
    final categories = categoriesAsync.when(
      data: (items) => ['Semua', ...items.map((c) => c.name)],
      loading: () => const ['Semua'],
      error: (_, __) => const ['Semua'],
    );
    if (selectedCategoryIndex >= categories.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedProductCategoryIndexProvider.notifier).setIndex(0);
      });
    }
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context, ref),
                _buildCategories(context, ref, categories),
                const SizedBox(height: 12),
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      final filteredProducts = selectedCategoryIndex == 0
                          ? products
                          : products
                              .where(
                                (product) =>
                                    product.category ==
                                    categories[selectedCategoryIndex],
                              )
                              .toList();
                      final searchedProducts = _filterProductsByQuery(
                        filteredProducts,
                        searchQuery,
                      );
                      if (searchedProducts.isEmpty) {
                        return const Center(child: Text('Belum ada produk.'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: searchedProducts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _ProductInventoryCard(
                            product: searchedProducts[index],
                            canEdit: isAdmin,
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text('Gagal memuat produk: $error'),
                    ),
                  ),
                ),
              ],
            ),
            if (isAdmin)
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  onPressed: () => context.push('/products/add'),
                  backgroundColor: const Color(0xFF00BFA5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Product> _filterProductsByQuery(
    List<Product> products,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return products;
    return products.where((product) {
      final name = product.name.toLowerCase();
      final sku = product.id.toLowerCase();
      return name.contains(trimmed) || sku.contains(trimmed);
    }).toList();
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari produk atau SKU...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: isDark ? colorScheme.surface : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                cursorColor: colorScheme.primary,
                onChanged: (value) => ref
                    .read(productListSearchQueryProvider.notifier)
                    .setQuery(value),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              color: colorScheme.onSurface,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(
    BuildContext context,
    WidgetRef ref,
    List<String> categories,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = ref.watch(selectedProductCategoryIndexProvider);
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return ChoiceChip(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            label: Text(
              categories[index],
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => ref
                .read(selectedProductCategoryIndexProvider.notifier)
                .setIndex(index),
            backgroundColor: colorScheme.surface,
            selectedColor: colorScheme.primaryContainer,
            side: BorderSide(
              color:
                  isSelected ? Colors.transparent : colorScheme.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

class _ProductInventoryCard extends StatelessWidget {
  final Product product;
  final bool canEdit;
  const _ProductInventoryCard({
    required this.product,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final isLowStock = product.stock < 10;
    final imageUrl = (product.imageUrl ?? '').isNotEmpty
        ? product.imageUrl
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Icon(Icons.fastfood, color: colorScheme.onSurfaceVariant)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${product.id.length > 7 ? product.id.substring(0, 7).toUpperCase() : product.id.toUpperCase()}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currency.format(product.priceLocal),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isLowStock
                      ? const Color(0xFFFEEBEB)
                      : colorScheme.surfaceVariant.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Stok: ${product.stock}',
                  style: TextStyle(
                    color: isLowStock
                        ? const Color(0xFFE53935)
                        : colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (canEdit) ...[
                const SizedBox(width: 10),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => context.push('/products/edit', extra: product),
                  splashRadius: 20,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
