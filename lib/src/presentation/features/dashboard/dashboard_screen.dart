
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../history/history_models.dart';
import '../history/transactions_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  ChartRange _chartRange = ChartRange.week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(transactionsProvider);
    final transactions = transactionsAsync.value ?? const <HistoryTransaction>[];
    final selectedTransactions =
        _filterByDate(transactions, _selectedDate);
    final totalRevenue = _calculateTotalRevenue(selectedTransactions);
    final transactionCount = selectedTransactions
        .where((t) => t.status == TransactionStatus.success)
        .length;
    final average = transactionCount == 0 ? 0 : totalRevenue / transactionCount;
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final compact = NumberFormat.compact(locale: 'id_ID');
    final totalText =
        transactionsAsync.isLoading ? 'Memuat...' : currency.format(totalRevenue);
    final countText =
        transactionsAsync.isLoading ? '...' : '$transactionCount';
    final averageText = transactionsAsync.isLoading
        ? '...'
        : 'Rp ${compact.format(average)}';
    final trendText = transactionsAsync.isLoading
        ? 'Memuat...'
        : _formatTrendText(transactions, _selectedDate);
    final recentTransactions = transactions.take(3).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildMainStatCard(context, totalText, trendText),
              const SizedBox(height: 16),
              _buildSecondaryStats(context, countText, averageText),
              const SizedBox(height: 24),
              _buildSalesChart(context, transactionsAsync, _chartRange),
              const SizedBox(height: 24),
              _buildRecentTransactions(context, recentTransactions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Admin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Moh Alif Al Lukman', // Mock Name
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Mock Avatar
              backgroundColor: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainStatCard(
    BuildContext context,
    String totalText,
    String trendText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedLabel = _selectedDateLabel();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Penjualan',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _pickDate(context),
                  child: Row(
                    children: [
                      Text(
                        selectedLabel,
                        style: TextStyle(color: colorScheme.onPrimary, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: colorScheme.onPrimary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            totalText,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.show_chart, color: colorScheme.onPrimary, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                trendText,
                style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStats(
    BuildContext context,
    String transactionCount,
    String averageText,
  ) {
    return Row(
      children: [
        Expanded(
          child: _SecondaryStatCard(
            label: 'Transaksi',
            value: transactionCount,
            subValue: '',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SecondaryStatCard(
            label: 'Rata-rata',
            value: averageText,
            subValue: '',
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart(
    BuildContext context,
    AsyncValue<List<HistoryTransaction>> transactionsAsync,
    ChartRange range,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    if (transactionsAsync.isLoading) {
      return _ChartContainer(
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final transactions = transactionsAsync.value ?? const <HistoryTransaction>[];
    final series = _buildRangeSeries(transactions, range);
    if (series.values.every((value) => value <= 0)) {
      return _ChartContainer(
        child: const Center(child: Text('Belum ada penjualan untuk rentang ini.')),
      );
    }

    final maxValue = series.values.reduce((a, b) => a > b ? a : b);
    final barColor = colorScheme.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Grafik Penjualan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<ChartRange>(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              initialValue: range,
              onSelected: (value) => setState(() => _chartRange = value),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: ChartRange.week,
                  child: Text('7 Hari Terakhir'),
                ),
                PopupMenuItem(
                  value: ChartRange.month,
                  child: Text('30 Hari Terakhir'),
                ),
              ],
            ),
          ],
        ),
          const SizedBox(height: 16),
          _ChartContainer(
            child: BarChart(
              BarChartData(
                maxY: maxValue == 0 ? 1 : maxValue,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= series.labels.length) {
                          return const SizedBox.shrink();
                        }
                        if (range == ChartRange.month && index % 5 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            series.labels[index],
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(series.values.length, (index) {
                  final value = series.values[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: barColor,
                        width: range == ChartRange.month ? 6 : 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    List<HistoryTransaction> transactions,
  ) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaksi Terakhir',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/history'),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Belum ada transaksi.'),
          )
        else
          ...transactions.map(
            (transaction) {
              final methodLabel = switch (transaction.paymentMethod) {
                PaymentMethod.cash => 'Tunai',
                PaymentMethod.qris => 'QRIS',
                PaymentMethod.debit => 'Debit',
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TransactionItem(
                  id: transaction.id,
                  time: DateFormat.Hm().format(transaction.dateTime),
                  method: methodLabel,
                  amount: currency.format(transaction.amount),
                  icon: _iconForPayment(transaction.paymentMethod),
                  iconColor: _colorForPayment(transaction.paymentMethod),
                ),
              );
            },
          ),
        // Add padding at bottom for FAB or just scrolling space
        const SizedBox(height: 80), 
      ],
    );
  }

  static List<HistoryTransaction> _filterByDate(
    List<HistoryTransaction> transactions,
    DateTime date,
  ) {
    final sel = DateTime(date.year, date.month, date.day);
    return transactions.where((t) {
      final d = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      return d == sel;
    }).toList();
  }

  static double _calculateTotalRevenue(List<HistoryTransaction> transactions) {
    return transactions
        .where((t) => t.status == TransactionStatus.success)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  String _selectedDateLabel() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    if (selected == todayDate) {
      return 'Hari Ini';
    }
    return DateFormat('d MMM yyyy', 'id_ID').format(selected);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _selectedDate = picked;
    });
  }

  static String _formatTrendText(
    List<HistoryTransaction> transactions,
    DateTime selectedDate,
  ) {
    final base = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final previous = base.subtract(const Duration(days: 1));

    double totalFor(DateTime date) {
      return transactions
          .where((t) => t.status == TransactionStatus.success)
          .where((t) {
            final d = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
            return d == date;
          })
          .fold(0.0, (sum, t) => sum + t.amount);
    }

    final todayTotal = totalFor(base);
    final yesterdayTotal = totalFor(previous);

    if (yesterdayTotal == 0) {
      if (todayTotal == 0) {
        return '0% dari kemarin';
      }
      return '+100% dari kemarin';
    }

    final diff = todayTotal - yesterdayTotal;
    final percent = (diff / yesterdayTotal) * 100;
    final sign = percent >= 0 ? '+' : '';
    return '${sign}${percent.toStringAsFixed(0)}% dari kemarin';
  }

  static IconData _iconForPayment(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => Icons.attach_money,
      PaymentMethod.qris => Icons.qr_code,
      PaymentMethod.debit => Icons.credit_card,
    };
  }

  static Color _colorForPayment(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => Colors.orange,
      PaymentMethod.qris => Colors.purple,
      PaymentMethod.debit => Colors.blue,
    };
  }
}

class _SecondaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;

  const _SecondaryStatCard({
    required this.label,
    required this.value,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

_ChartSeries _buildRangeSeries(
  List<HistoryTransaction> transactions,
  ChartRange range,
) {
  final now = DateTime.now();
  final count = range == ChartRange.week ? 7 : 30;
  final base = DateTime(now.year, now.month, now.day);
  final days = List.generate(count, (index) {
    return base.subtract(Duration(days: count - 1 - index));
  });
  final values = List<double>.filled(count, 0);

  final indexByDate = <DateTime, int>{};
  for (var i = 0; i < days.length; i++) {
    indexByDate[days[i]] = i;
  }

  for (final transaction in transactions) {
    if (transaction.status != TransactionStatus.success) continue;
    final date = DateTime(
      transaction.dateTime.year,
      transaction.dateTime.month,
      transaction.dateTime.day,
    );
    final index = indexByDate[date];
    if (index != null) {
      values[index] += transaction.amount;
    }
  }

  final formatter = DateFormat(range == ChartRange.week ? 'E' : 'd', 'id_ID');
  final labels = days.map((d) => formatter.format(d)).toList();

  return _ChartSeries(labels: labels, values: values);
}

class _ChartSeries {
  final List<String> labels;
  final List<double> values;

  const _ChartSeries({required this.labels, required this.values});
}

enum ChartRange { week, month }

class _ChartContainer extends StatelessWidget {
  final Widget child;

  const _ChartContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String id;
  final String time;
  final String method;
  final String amount;
  final IconData icon;
  final Color iconColor;

  const _TransactionItem({
    required this.id,
    required this.time,
    required this.method,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$time • $method',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sukses',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
