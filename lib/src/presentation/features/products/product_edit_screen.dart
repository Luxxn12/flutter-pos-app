import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/product_repository.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../categories/categories_provider.dart';
import '../transactions/pos_state.dart';
import '../auth/auth_provider.dart';
import '../../widgets/top_toast.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  final Product? product;
  const ProductEditScreen({super.key, this.product});

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _stockController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _costPriceController;
  bool _isActive = true;
  bool _trackStock = true;
  bool _isSaving = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _isActive = p?.isActive ?? true;
    _trackStock = p?.trackStock ?? true;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(
      text: p == null
          ? ''
          : p.id.length > 7
          ? p.id.substring(0, 7).toUpperCase()
          : p.id.toUpperCase(),
    );
    _stockController = TextEditingController(
      text: p != null ? '${p.stock}' : '',
    );
    _selectedCategory = p?.category;
    final currency = NumberFormat.decimalPattern('id');
    _sellPriceController = TextEditingController(
      text: p != null ? currency.format(p.priceLocal) : '',
    );
    _costPriceController = TextEditingController(
      text: p != null ? currency.format(p.priceForeign) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _sellPriceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final labelColor = colorScheme.primary;
    final primaryColor = colorScheme.primary;
    final redButton = colorScheme.error;
    final textColor = colorScheme.onSurface;
    final categoriesAsync = ref.watch(categoriesProvider);

    if (!isAdmin) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 48, color: textColor),
                  const SizedBox(height: 12),
                  Text(
                    'Akses produk dibatasi untuk kasir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: textColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 22,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.product == null ? 'Tambah Produk' : 'Edit Produk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledField(
                      label: 'Nama Produk',
                      controller: _nameController,
                      labelColor: labelColor,
                      textInputAction: TextInputAction.next,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'SKU',
                            controller: _skuController,
                            labelColor: labelColor,
                            textInputAction: TextInputAction.next,
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Stok',
                            controller: _stockController,
                            labelColor: labelColor,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _CategoryField(
                      labelColor: labelColor,
                      textColor: textColor,
                      categoriesAsync: categoriesAsync,
                      selectedCategory: _selectedCategory,
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      onManage: () => context.push('/categories'),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Harga Lokal (Rp)',
                      controller: _sellPriceController,
                      labelColor: labelColor,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Harga Bule (Rp)',
                      controller: _costPriceController,
                      labelColor: labelColor,
                      keyboardType: TextInputType.number,
                      helperText: 'Tidak ditampilkan di struk',
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _SwitchRow(
                      label: 'Status Aktif',
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      activeColor: primaryColor,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    _SwitchRow(
                      label: 'Lacak Stok',
                      value: _trackStock,
                      onChanged: (value) => setState(() => _trackStock = value),
                      activeColor: primaryColor,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
                color: colorScheme.surface,
              ),
              child: Row(
                children: [
                  if (widget.product != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _confirmDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: redButton,
                          side: BorderSide(color: redButton, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Hapus'),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final category = _selectedCategory?.trim() ?? '';
    if (name.isEmpty || category.isEmpty) {
      showTopToast(
        context,
        message: 'Nama dan kategori wajib diisi.',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isSaving = true);
    final price = _parseCurrency(_sellPriceController.text);
    final priceForeign = _parseCurrency(_costPriceController.text);
    if (price <= 0 || priceForeign <= 0) {
      showTopToast(
        context,
        message: 'Harga lokal dan bule wajib diisi.',
        type: ToastType.error,
      );
      setState(() => _isSaving = false);
      return;
    }
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    final input = ProductInput(
      name: name,
      priceLocal: price,
      priceForeign: priceForeign,
      category: category,
      stock: stock,
      imageUrl: null,
      isActive: _isActive,
      trackStock: _trackStock,
    );

    try {
      if (widget.product == null) {
        await ref.read(productsProvider.notifier).createProduct(input);
        if (mounted) {
          showTopToast(
            context,
            message: 'Produk berhasil ditambahkan.',
            type: ToastType.success,
          );
        }
      } else {
        await ref
            .read(productsProvider.notifier)
            .updateProduct(widget.product!.id, input);
        if (mounted) {
          showTopToast(
            context,
            message: 'Produk berhasil diperbarui.',
            type: ToastType.success,
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Gagal menyimpan produk: $error',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || widget.product == null) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(productsProvider.notifier)
          .deleteProduct(widget.product!.id);
      if (mounted) {
        showTopToast(
          context,
          message: 'Produk berhasil dihapus.',
          type: ToastType.success,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Gagal menghapus produk: $error',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  double _parseCurrency(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return double.tryParse(digits) ?? 0;
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color labelColor;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? helperText;
  final TextStyle? textStyle;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.labelColor,
    this.keyboardType,
    this.textInputAction,
    this.helperText,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: labelColor, width: 1.5),
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          style:
              textStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

class _CategoryField extends StatelessWidget {
  final Color labelColor;
  final Color textColor;
  final AsyncValue<List<Category>> categoriesAsync;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  final VoidCallback onManage;

  const _CategoryField({
    required this.labelColor,
    required this.textColor,
    required this.categoriesAsync,
    required this.selectedCategory,
    required this.onChanged,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Kategori',
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton(
                onPressed: onManage,
                child: const Text('Kelola'),
              ),
            ],
          ),
        ),
        categoriesAsync.when(
          data: (categories) {
            final names = categories
                .map((category) => category.name)
                .toSet()
                .toList()
              ..sort();
            if (selectedCategory != null &&
                selectedCategory!.isNotEmpty &&
                !names.contains(selectedCategory)) {
              names.insert(0, selectedCategory!);
            }

            return DropdownButtonFormField<String>(
              value: selectedCategory,
              items: names
                  .map(
                    (name) => DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: colorScheme.outlineVariant, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: colorScheme.outlineVariant, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: labelColor, width: 1.5),
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(
            'Gagal memuat kategori: $error',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color textColor;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return activeColor;
            return null;
          }),
        ),
      ],
    );
  }
}
