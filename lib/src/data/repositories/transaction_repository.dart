import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../presentation/features/history/history_models.dart';
import '../../presentation/features/transactions/pos_state.dart';
import '../../presentation/features/settings/store_settings_provider.dart';
import '../supabase/supabase_providers.dart';

class TransactionRepository {
  TransactionRepository(
    this._client, {
    required this.defaultStoreName,
    required this.defaultStoreAddress,
  });

  final SupabaseClient _client;
  final String defaultStoreName;
  final String defaultStoreAddress;

  Future<List<HistoryTransaction>> fetchTransactions() async {
    final data = await _client
        .from('transactions')
        .select(
          'id,order_no,cashier,total_amount,tax,discount,status,payment_method,received,store_name,store_address,created_at,transaction_items(name,quantity,price)',
        )
        .order('created_at', ascending: false);

    return data.map<HistoryTransaction>((row) {
      final items = (row['transaction_items'] as List<dynamic>? ?? [])
          .map(
            (item) => HistoryLineItem(
              name: item['name'] as String? ?? '-',
              quantity: (item['quantity'] as num?)?.toInt() ?? 0,
              price: _toDouble(item['price']),
            ),
          )
          .toList();

      return HistoryTransaction(
        id: row['order_no'] as String? ?? '#ORD-UNKNOWN',
        cashier: row['cashier'] as String? ?? 'Kasir',
        dateTime: DateTime.tryParse(row['created_at'] as String? ?? '') ??
            DateTime.now(),
        amount: _toDouble(row['total_amount']),
        status: _statusFromDb(row['status'] as String?),
        paymentMethod: _paymentFromDb(row['payment_method'] as String?),
        storeName: _fallbackStoreValue(
          row['store_name'] as String?,
          defaultStoreName,
        ),
        storeAddress: _fallbackStoreValue(
          row['store_address'] as String?,
          defaultStoreAddress,
        ),
        items: items,
        tax: _toDouble(row['tax']),
        discount: _toDouble(row['discount']),
        received: _toDouble(row['received']),
      );
    }).toList();
  }

  Future<HistoryTransaction> createTransaction({
    required List<CartItem> cart,
    required double total,
    required double tax,
    required PaymentMethod paymentMethod,
    required double received,
    required String priceType,
    required double Function(CartItem item) priceResolver,
    String cashier = 'Kasir',
    String? storeName,
    String? storeAddress,
  }) async {
    final now = DateTime.now();
    final resolvedStoreName = _fallbackStoreValue(
      storeName,
      defaultStoreName,
    );
    final resolvedStoreAddress = _fallbackStoreValue(
      storeAddress,
      defaultStoreAddress,
    );
    final orderNo = '#ORD-${DateFormat('ddHHmmss').format(now)}';
    final inserted = await _client
        .from('transactions')
        .insert({
          'order_no': orderNo,
          'cashier': cashier,
          'total_amount': total,
          'tax': tax,
          'discount': 0,
          'status': TransactionStatus.success.name,
          'payment_method': paymentMethod.name,
          'received': received,
          'price_type': priceType,
          'store_name': resolvedStoreName,
          'store_address': resolvedStoreAddress,
        })
        .select('id')
        .single();

    final transactionId = inserted['id'] as String;
    final itemsPayload = cart
        .map(
          (item) => {
            'transaction_id': transactionId,
            'product_id': item.product.id,
            'name': item.product.name,
            'quantity': item.quantity,
            'price': priceResolver(item),
          },
        )
        .toList();

    if (itemsPayload.isNotEmpty) {
      await _client.from('transaction_items').insert(itemsPayload);
    }

    final items = cart
        .map(
          (item) => HistoryLineItem(
            name: item.product.name,
            quantity: item.quantity,
            price: priceResolver(item),
          ),
        )
        .toList();

    return HistoryTransaction(
      id: orderNo,
      cashier: cashier,
      dateTime: now,
      amount: total,
      status: TransactionStatus.success,
      paymentMethod: paymentMethod,
      storeName: resolvedStoreName,
      storeAddress: resolvedStoreAddress,
      items: items,
      tax: tax,
      discount: 0,
      received: received,
    );
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final storeProfile = ref.watch(storeProfileProvider);
  return TransactionRepository(
    ref.read(supabaseClientProvider),
    defaultStoreName: storeProfile.name,
    defaultStoreAddress: storeProfile.address,
  );
});

TransactionStatus _statusFromDb(String? value) {
  switch (value) {
    case 'failed':
      return TransactionStatus.failed;
    case 'success':
    default:
      return TransactionStatus.success;
  }
}

String _fallbackStoreValue(String? value, String fallback) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return fallback;
  return trimmed;
}

PaymentMethod _paymentFromDb(String? value) {
  switch (value) {
    case 'qris':
      return PaymentMethod.qris;
    case 'debit':
      return PaymentMethod.debit;
    case 'cash':
    default:
      return PaymentMethod.cash;
  }
}

double _toDouble(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
