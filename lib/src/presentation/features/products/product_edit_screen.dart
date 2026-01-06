import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/product.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product;
  const ProductEditScreen({super.key, this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _stockController;
  late final TextEditingController _categoryController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _costPriceController;
  bool _isActive = true;
  bool _trackStock = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
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
    _categoryController = TextEditingController(text: p?.category ?? '');
    final currency = NumberFormat.decimalPattern('id');
    _sellPriceController = TextEditingController(
      text: p != null ? currency.format(p.price) : '',
    );
    _costPriceController = TextEditingController(
      text: p != null ? currency.format((p.price * 0.63).round()) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _sellPriceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final labelColor = colorScheme.primary;
    final primaryColor = colorScheme.primary;
    final redButton = colorScheme.error;
    final textColor = colorScheme.onSurface;

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
                    _LabeledField(
                      label: 'Kategori',
                      controller: _categoryController,
                      labelColor: labelColor,
                      textInputAction: TextInputAction.next,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Harga Jual (Rp)',
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
                      label: 'Harga Modal (Rp)',
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
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
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
