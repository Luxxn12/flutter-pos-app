import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'history_models.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int _selectedPaymentIndex = 0;
  DateTime _selectedDate = DateTime.now();

  List<HistoryTransaction> get _transactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return [
      HistoryTransaction(
        id: '#ORD-2410-008',
        cashier: 'Budi Santoso',
        dateTime: today.add(const Duration(hours: 14, minutes: 32)),
        amount: 125000,
        status: TransactionStatus.success,
        paymentMethod: PaymentMethod.cash,
        storeName: 'Kopi Senja Utama',
        storeAddress: 'Jl. Melati No. 12, Jakarta Selatan',
        items: const [
          HistoryLineItem(
            name: 'Kopi Susu Gula Aren',
            quantity: 2,
            price: 25000,
          ),
          HistoryLineItem(name: 'Croissant Butter', quantity: 2, price: 25000),
          HistoryLineItem(
            name: 'Original Cheese Cake',
            quantity: 1,
            price: 25000,
          ),
        ],
        tax: 0,
        discount: 0,
        received: 130000,
      ),
      HistoryTransaction(
        id: '#ORD-2410-007',
        cashier: 'Kasir Siti',
        dateTime: today.add(const Duration(hours: 13, minutes: 15)),
        amount: 45000,
        status: TransactionStatus.success,
        paymentMethod: PaymentMethod.cash,
        storeName: 'Kopi Senja Utama',
        storeAddress: 'Jl. Melati No. 12, Jakarta Selatan',
        items: const [
          HistoryLineItem(name: 'Iced Americano', quantity: 1, price: 20000),
          HistoryLineItem(name: 'Cinnamon Roll', quantity: 1, price: 25000),
        ],
        tax: 0,
        discount: 0,
        received: 50000,
      ),
      HistoryTransaction(
        id: '#ORD-2410-006',
        cashier: 'Kasir Budi',
        dateTime: today.add(const Duration(hours: 11, minutes: 20)),
        amount: 210000,
        status: TransactionStatus.success,
        paymentMethod: PaymentMethod.qris,
        storeName: 'Kopi Senja Utama',
        storeAddress: 'Jl. Melati No. 12, Jakarta Selatan',
        items: const [
          HistoryLineItem(name: 'Paket Sarapan', quantity: 3, price: 70000),
        ],
        tax: 0,
        discount: 0,
        received: 210000,
      ),
      HistoryTransaction(
        id: '#ORD-2310-095',
        cashier: 'Admin',
        dateTime: yesterday.add(const Duration(hours: 19, minutes: 45)),
        amount: 88000,
        status: TransactionStatus.failed,
        paymentMethod: PaymentMethod.debit,
        storeName: 'Kopi Senja Utama',
        storeAddress: 'Jl. Melati No. 12, Jakarta Selatan',
        items: const [
          HistoryLineItem(name: 'Affogato', quantity: 2, price: 22000),
          HistoryLineItem(name: 'Kue Lapis', quantity: 2, price: 22000),
        ],
        tax: 0,
        discount: 0,
        received: 88000,
      ),
      HistoryTransaction(
        id: '#ORD-2310-094',
        cashier: 'Kasir Siti',
        dateTime: yesterday.add(const Duration(hours: 18, minutes: 10)),
        amount: 150000,
        status: TransactionStatus.success,
        paymentMethod: PaymentMethod.qris,
        storeName: 'Kopi Senja Utama',
        storeAddress: 'Jl. Melati No. 12, Jakarta Selatan',
        items: const [
          HistoryLineItem(name: 'Latte', quantity: 2, price: 30000),
          HistoryLineItem(name: 'Tiramisu', quantity: 2, price: 45000),
        ],
        tax: 0,
        discount: 0,
        received: 150000,
      ),
      HistoryTransaction(
        id: '#ORD-2310-093',
        cashier: 'Kasir Budi',
        dateTime: yesterday.add(const Duration(hours: 17, minutes: 30)),
        amount: 32500,
        status: TransactionStatus.success,
        paymentMethod: PaymentMethod.cash,
        storeName: 'Kopi Senja Utama',
        storeAddress: 'Jl. Melati No. 12, Jakarta Selatan',
        items: const [
          HistoryLineItem(name: 'Roti Bakar Coklat', quantity: 1, price: 15000),
          HistoryLineItem(name: 'Teh Tarik', quantity: 1, price: 17500),
        ],
        tax: 0,
        discount: 0,
        received: 50000,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _selectedPaymentIndex == 0
        ? _transactions
        : _transactions
              .where((t) => t.paymentMethod.index == _selectedPaymentIndex - 1)
              .toList();

    final dateFiltered = filtered.where((t) {
      final d = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      final sel = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      return d == sel;
    }).toList();

    final grouped = _groupByDate(dateFiltered);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            _buildFilterChips(colorScheme),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final entry = grouped.entries.elementAt(index);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        color: colorScheme.surfaceVariant.withOpacity(0.6),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      ...entry.value.map(_buildTransactionTile).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Riwayat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _dateLabel(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Pendapatan',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _currency.format(3450000),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    const filters = ['Semua', 'Tunai', 'QRIS', 'Kartu Debit'];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            final selected = _selectedPaymentIndex == index;
            return Padding(
              padding: EdgeInsets.only(
                right: index == filters.length - 1 ? 0 : 12,
              ),
              child: ChoiceChip(
                label: Text(
                  filters[index],
                  style: TextStyle(
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                selected: selected,
                onSelected: (_) => setState(() {
                  _selectedPaymentIndex = index;
                }),
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primaryContainer,
                side: BorderSide(
                  color: selected
                      ? Colors.transparent
                      : colorScheme.outlineVariant,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                showCheckmark: false,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(HistoryTransaction item) {
    return InkWell(
      onTap: () => context.push('/history/detail', extra: item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.id,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat.Hm().format(item.dateTime)} • ${item.cashier}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currency.format(item.amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item.status == TransactionStatus.success
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.status == TransactionStatus.success
                        ? 'Sukses'
                        : 'Batal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: item.status == TransactionStatus.success
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<HistoryTransaction>> _groupByDate(
    List<HistoryTransaction> items,
  ) {
    final now = DateTime.now();
    items.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final Map<String, List<HistoryTransaction>> grouped = {};

    for (final item in items) {
      final date = DateTime(
        item.dateTime.year,
        item.dateTime.month,
        item.dateTime.day,
      );
      final difference = now.difference(date).inDays;
      final dateLabel = switch (difference) {
        0 => 'Hari Ini, ${DateFormat('d MMM yyyy', 'id_ID').format(date)}',
        1 => 'Kemarin, ${DateFormat('d MMM yyyy', 'id_ID').format(date)}',
        _ => DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date),
      };

      grouped.putIfAbsent(dateLabel, () => []).add(item);
    }

    return grouped;
  }

  String _dateLabel() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    if (selDate == todayDate) {
      return 'Hari Ini';
    }
    return DateFormat('d MMM yyyy', 'id_ID').format(_selectedDate);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });
  }
}
