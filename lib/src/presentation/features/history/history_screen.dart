import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'history_models.dart';
import 'transactions_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final transactionsAsync = ref.watch(transactionsProvider);
    final totalText = transactionsAsync.when(
      data: (transactions) {
        final filtered = _filterByPayment(transactions);
        final dateFiltered = _filterByDate(filtered);
        final total = _calculateTotalRevenue(dateFiltered);
        return _currency.format(total);
      },
      loading: () => 'Memuat...',
      error: (_, __) => _currency.format(0),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme, totalText),
            _buildFilterChips(colorScheme),
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) {
                  final filtered = _filterByPayment(transactions);
                  final dateFiltered = _filterByDate(filtered);
                  final grouped = _groupByDate(dateFiltered);
                  if (grouped.isEmpty) {
                    return const Center(child: Text('Belum ada transaksi.'));
                  }

                  return ListView.builder(
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
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Gagal memuat transaksi: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, String totalText) {
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
              // Container(
              //   height: 48,
              //   width: 48,
              //   decoration: BoxDecoration(
              //     color: colorScheme.surfaceVariant.withOpacity(0.6),
              //     borderRadius: BorderRadius.circular(24),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.04),
              //         blurRadius: 10,
              //         offset: const Offset(0, 6),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 20),
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
                    totalText,
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
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = _selectedPaymentIndex == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == filters.length - 1 ? 0 : 8,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() {
                  _selectedPaymentIndex = index;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? colorScheme.primaryContainer
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filters[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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

  List<HistoryTransaction> _filterByPayment(
    List<HistoryTransaction> transactions,
  ) {
    if (_selectedPaymentIndex == 0) {
      return transactions;
    }
    return transactions
        .where(
          (t) => t.paymentMethod.index == _selectedPaymentIndex - 1,
        )
        .toList();
  }

  List<HistoryTransaction> _filterByDate(
    List<HistoryTransaction> transactions,
  ) {
    final sel = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return transactions.where((t) {
      final d = DateTime(
        t.dateTime.year,
        t.dateTime.month,
        t.dateTime.day,
      );
      return d == sel;
    }).toList();
  }

  double _calculateTotalRevenue(List<HistoryTransaction> transactions) {
    return transactions
        .where((t) => t.status == TransactionStatus.success)
        .fold(0.0, (sum, t) => sum + t.amount);
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
