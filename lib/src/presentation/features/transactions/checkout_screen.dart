import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../features/history/history_models.dart';
import '../../features/history/transactions_provider.dart';
import 'pos_state.dart';
import '../settings/tax_settings_provider.dart';
import '../settings/store_settings_provider.dart';
import '../../widgets/top_toast.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'Tunai'; // Tunai, QRIS, Kartu
  final TextEditingController _paymentController = TextEditingController();
  double _paymentAmount = 0;
  bool _useForeignPrice = false;
  late final ProviderSubscription<List<CartItem>> _cartSubscription;
  late final ProviderSubscription<TaxSettings> _taxSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize payment amount with total
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPaymentWithTotal();
    });

    _cartSubscription = ref.listenManual<List<CartItem>>(
      cartProvider,
      (_, __) => _syncPaymentWithTotal(),
    );
    _taxSubscription = ref.listenManual<TaxSettings>(
      taxSettingsProvider,
      (_, __) => _syncPaymentWithTotal(),
    );
  }

  @override
  void dispose() {
    _cartSubscription.close();
    _taxSubscription.close();
    _paymentController.dispose();
    super.dispose();
  }

  void _updatePaymentAmount(double amount) {
    setState(() {
      _paymentAmount = amount;
      _paymentController.text = amount.toInt().toString();
    });
  }

  Future<void> _handlePay(double total, double tax) async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final method = _mapPaymentMethod(_selectedPaymentMethod);
    final received = method == PaymentMethod.cash ? _paymentAmount : total;
    final priceType = _useForeignPrice ? 'foreign' : 'local';
    final priceResolver = (CartItem item) =>
        _useForeignPrice ? item.product.priceForeign : item.product.priceLocal;
    final storeProfile = ref.read(storeProfileProvider);

    final transactionRepo = ref.read(transactionRepositoryProvider);
    final productRepo = ref.read(productRepositoryProvider);

    try {
      final transaction =
          await ref.read(transactionsProvider.notifier).createTransaction(
        () => transactionRepo.createTransaction(
          cart: cart,
          total: total,
          tax: tax,
          paymentMethod: method,
          received: received,
          priceType: priceType,
          priceResolver: priceResolver,
          storeName: storeProfile.name,
          storeAddress: storeProfile.address,
        ),
      );

      for (final item in cart) {
        await productRepo.decrementStock(item.product.id, item.quantity);
      }
      await ref.read(productsProvider.notifier).refresh();
      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        showTopToast(
          context,
          message: 'Transaksi berhasil dibuat.',
          type: ToastType.success,
        );
        context.push('/history/detail', extra: transaction);
      }
    } catch (error) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Gagal membuat transaksi: $error',
          type: ToastType.error,
        );
      }
    }
  }

  PaymentMethod _mapPaymentMethod(String method) {
    switch (method) {
      case 'QRIS':
        return PaymentMethod.qris;
      case 'Kartu':
        return PaymentMethod.debit;
      case 'Tunai':
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final taxSettings = ref.watch(taxSettingsProvider);
    final subtotal = _calculateSubtotal(cart);
    final taxRate = _effectiveTaxRate(taxSettings);
    final tax = subtotal * taxRate;
    final total = subtotal + tax;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final surfaceVariant = colorScheme.surfaceVariant;
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PESANAN SECTION ---
                  const Text(
                    'PESANAN',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                // Placeholder for 'Extra Cheese' etc.
                                const SizedBox(height: 4),
                                Text(
                                  item.product.category,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currency.format(_priceForItem(item)),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Qty Control
                          Row(
                            children: [
                              _QtyBox(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: () => ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                        item.id,
                                        item.quantity - 1,
                                      ),
                                ),
                              ),
                              Container(
                                color: surfaceVariant.withOpacity(0.6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _QtyBox(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () => ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                        item.id,
                                        item.quantity + 1,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 48),

                  // --- METODE PEMBAYARAN ---
                  const Text(
                    'METODE PEMBAYARAN',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'JENIS HARGA',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _PriceTypeButton(
                          label: 'Lokal',
                          isSelected: !_useForeignPrice,
                          onTap: () => _setPriceType(false),
                          colorScheme: colorScheme,
                        ),
                        _PriceTypeButton(
                          label: 'Bule',
                          isSelected: _useForeignPrice,
                          onTap: () => _setPriceType(true),
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: ['Tunai', 'QRIS', 'Kartu'].map((method) {
                        final isSelected = _selectedPaymentMethod == method;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedPaymentMethod = method),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary.withOpacity(0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: isSelected
                                    ? Border.all(
                                        color:
                                            colorScheme.primary.withOpacity(0.3),
                                      )
                                    : null,
                              ),
                              child: Text(
                                method,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  if (_selectedPaymentMethod == 'Tunai') ...[
                    const SizedBox(height: 24),
                    // Payment Amount Input
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Rp',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _paymentController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _paymentAmount = double.tryParse(val) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Quick Money Buttons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _QuickAmountBtn(
                            label: 'Uang Pas',
                            onTap: () => _updatePaymentAmount(total),
                          ),
                          const SizedBox(width: 8),
                          _QuickAmountBtn(
                            label: 'Rp 50.000',
                            onTap: () => _updatePaymentAmount(50000),
                          ),
                          const SizedBox(width: 8),
                          _QuickAmountBtn(
                            label: 'Rp 100.000',
                            onTap: () => _updatePaymentAmount(100000),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  // --- SUMMARY ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceVariant.withOpacity(0.5), // Theme aware bg
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Subtotal',
                          value: currency.format(subtotal),
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: _taxLabel(taxSettings),
                          value: currency.format(tax),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ), // Dotted line placeholder
                        _SummaryRow(
                          label: 'Total Tagihan',
                          value: currency.format(total),
                          isBold: true,
                          valueColor: colorScheme.onSurface,
                        ),
                        if (_selectedPaymentMethod == 'Tunai') ...[
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Kembalian',
                            value: currency.format(
                              _paymentAmount - total < 0
                                  ? 0
                                  : _paymentAmount - total,
                            ),
                            valueColor: const Color(0xFF00BFA5),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // --- BOTTOM ACTIONS ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed:
                        total <= 0 ? null : () => _handlePay(total, tax),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5), // Blue
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Bayar Sekarang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setPriceType(bool useForeign) {
    setState(() => _useForeignPrice = useForeign);
    final cart = ref.read(cartProvider);
    final subtotal = cart.fold<double>(0, (sum, item) {
      final price =
          useForeign ? item.product.priceForeign : item.product.priceLocal;
      return sum + price * item.quantity;
    });
    _updatePaymentAmount(_totalWithTax(subtotal));
  }

  double _calculateSubtotal(List<CartItem> cart) {
    return cart.fold<double>(0, (sum, item) {
      return sum + _priceForItem(item) * item.quantity;
    });
  }

  void _syncPaymentWithTotal() {
    final cart = ref.read(cartProvider);
    final subtotal = _calculateSubtotal(cart);
    final totalWithTax = _totalWithTax(subtotal);
    if (!mounted) return;
    _updatePaymentAmount(totalWithTax);
  }

  double _effectiveTaxRate(TaxSettings settings) {
    return settings.enabled ? settings.rate / 100 : 0;
  }

  double _totalWithTax(double subtotal) {
    final taxSettings = ref.read(taxSettingsProvider);
    return subtotal * (1 + _effectiveTaxRate(taxSettings));
  }

  String _taxLabel(TaxSettings settings) {
    final rateText = _formatTaxRate(settings.rate);
    return settings.enabled ? 'Pajak ($rateText%)' : 'Pajak (Nonaktif)';
  }

  String _formatTaxRate(double rate) {
    if (rate % 1 == 0) return rate.toInt().toString();
    return rate
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  double _priceForItem(CartItem item) {
    return _useForeignPrice
        ? item.product.priceForeign
        : item.product.priceLocal;
  }
}

class _PriceTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _PriceTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary.withOpacity(0.12) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyBox extends StatelessWidget {
  final Widget child;
  const _QtyBox({required this.child});

  @override
  Widget build(BuildContext context) {
    final outlineColor = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: outlineColor),
        borderRadius: BorderRadius.circular(4),
      ),
      width: 32,
      height: 32,
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _QuickAmountBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: isBold ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
