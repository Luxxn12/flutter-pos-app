import 'package:flutter/material.dart';

enum TransactionStatus { success, failed }

enum PaymentMethod { cash, qris, debit }

class HistoryLineItem {
  final String name;
  final int quantity;
  final double price;

  const HistoryLineItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get subtotal => price * quantity;
}

class HistoryTransaction {
  final String id;
  final String cashier;
  final DateTime dateTime;
  final double amount;
  final TransactionStatus status;
  final PaymentMethod paymentMethod;
  final String storeName;
  final String storeAddress;
  final List<HistoryLineItem> items;
  final double tax;
  final double discount;
  final double received;

  const HistoryTransaction({
    required this.id,
    required this.cashier,
    required this.dateTime,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.storeName,
    required this.storeAddress,
    required this.items,
    required this.tax,
    required this.discount,
    required this.received,
  });

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.subtotal) -
      discount +
      tax;

  double get change => (received - amount).clamp(0, double.infinity);

  Color get statusColor => status == TransactionStatus.success
      ? const Color(0xFF0D9F6E)
      : const Color(0xFFE74C3C);
}
