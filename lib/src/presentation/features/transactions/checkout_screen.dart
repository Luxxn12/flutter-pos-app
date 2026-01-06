import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../features/history/history_models.dart';
import 'pos_state.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'Tunai'; // Tunai, QRIS, Kartu
  final TextEditingController _paymentController = TextEditingController();
  double _paymentAmount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize payment amount with total
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final total = ref.read(cartTotalProvider);
      // Add tax 10%
      final totalWithTax = total * 1.1;
      _paymentController.text = totalWithTax.toInt().toString();
      setState(() {
        _paymentAmount = totalWithTax;
      });
    });
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  void _updatePaymentAmount(double amount) {
    setState(() {
      _paymentAmount = amount;
      _paymentController.text = amount.toInt().toString();
    });
  }

  void _handlePay(double total, double tax, double subtotal) {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final now = DateTime.now();
    final items = cart
        .map(
          (item) => HistoryLineItem(
            name: item.product.name,
            quantity: item.quantity,
            price: item.product.price,
          ),
        )
        .toList();

    final method = _mapPaymentMethod(_selectedPaymentMethod);
    final received = method == PaymentMethod.cash ? _paymentAmount : total;

    final transaction = HistoryTransaction(
      id: '#ORD-${DateFormat('ddHHmmss').format(now)}',
      cashier: 'Kasir',
      dateTime: now,
      amount: total,
      status: TransactionStatus.success,
      paymentMethod: method,
      storeName: 'Kopi Senja Utama',
      storeAddress: 'Jl. Melati No. 12, Jakarta Selatan',
      items: items,
      tax: tax,
      discount: 0,
      received: received,
    );

    context.push('/history/detail', extra: transaction);
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
    final subtotal = ref.watch(cartTotalProvider);
    final tax = subtotal * 0.1;
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
                                  currency.format(item.product.price),
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
                          label: 'Pajak (10%)',
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
                          valueColor: Colors.black,
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
                    onPressed: () => _handlePay(total, tax, subtotal),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
