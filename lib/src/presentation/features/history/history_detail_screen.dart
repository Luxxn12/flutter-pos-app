import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'history_models.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryTransaction transaction;

  const HistoryDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 18, color: colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Detail Transaksi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusPill(colorScheme),
              const SizedBox(height: 16),
              Text(
                currency.format(transaction.amount),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat(
                  'd MMM yyyy, HH:mm \'WIB\'',
                  'id_ID',
                ).format(transaction.dateTime),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailCard(currency, colorScheme),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Kirim',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cetak Struk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(ColorScheme colorScheme) {
    final isSuccess = transaction.status == TransactionStatus.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSuccess ? colorScheme.primary : colorScheme.error,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isSuccess ? 'Transaksi Berhasil' : 'Transaksi Batal',
        style: TextStyle(
          color: isSuccess ? colorScheme.onPrimary : colorScheme.onError,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDetailCard(NumberFormat currency, ColorScheme colorScheme) {
    final subtotal = transaction.items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  transaction.storeName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.storeAddress,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'No. Order',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                transaction.id,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kasir',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                transaction.cashier,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          ...transaction.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} x ${currency.format(item.price)}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currency.format(item.subtotal),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          _buildAmountRow(
            'Subtotal',
            currency.format(subtotal),
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _buildAmountRow(
            'Pajak (${_formatTaxRate(subtotal, transaction.tax)})',
            currency.format(transaction.tax),
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _buildAmountRow(
            'Diskon',
            '-${currency.format(transaction.discount)}',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 14),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          _buildAmountRow(
            'Total',
            currency.format(transaction.amount),
            isBold: true,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildAmountRow(
                  'Metode Bayar',
                  _paymentLabel(transaction.paymentMethod),
                  isBold: false,
                  valueColor: colorScheme.onSurface,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 10),
                _buildAmountRow(
                  'Diterima',
                  currency.format(transaction.received),
                  isBold: false,
                  valueColor: colorScheme.onSurface,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 10),
                _buildAmountRow(
                  'Kembalian',
                  currency.format(transaction.change),
                  isBold: false,
                  valueColor: colorScheme.onSurface,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    required ColorScheme colorScheme,
  }) {
    final resolvedValueColor = valueColor ?? colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: resolvedValueColor,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _paymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.debit:
        return 'Kartu Debit';
    }
  }

  String _formatTaxRate(double subtotal, double taxAmount) {
    if (subtotal <= 0) return '0%';
    final rate = (taxAmount / subtotal) * 100;
    final formatted = rate % 1 == 0
        ? rate.toInt().toString()
        : rate.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return '$formatted%';
  }
}
