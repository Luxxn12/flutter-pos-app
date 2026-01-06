
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
              _buildMainStatCard(context),
              const SizedBox(height: 16),
              _buildSecondaryStats(context),
              const SizedBox(height: 24),
              _buildSalesChart(context),
              const SizedBox(height: 24),
              _buildRecentTransactions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Kasir',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Budi Santoso', // Mock Name
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Senin, 24 Okt 2023', // Mock Date
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

  Widget _buildMainStatCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                child: Row(
                  children: [
                    Text('Hari Ini', style: TextStyle(color: colorScheme.onPrimary, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: colorScheme.onPrimary, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rp 2.850.000',
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
                '+12% dari kemarin',
                style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SecondaryStatCard(
            label: 'Transaksi',
            value: '42',
            subValue: '',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SecondaryStatCard(
            label: 'Rata-rata',
            value: '67.8rb',
            subValue: '',
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
            ),
          ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ChartBar(height: 0.4, isSelected: false),
              _ChartBar(height: 0.6, isSelected: false),
              _ChartBar(height: 0.3, isSelected: false),
              _ChartBar(height: 0.7, isSelected: false),
              _ChartBar(height: 0.5, isSelected: false),
              _ChartBar(height: 0.8, isSelected: true), // Highlighted
              _ChartBar(height: 0.6, isSelected: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
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
              onPressed: () {},
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const _TransactionItem(
          id: '#TRX-8823',
          time: '10:42',
          method: 'Tunai',
          amount: 'Rp 45.000',
          icon: Icons.coffee,
          iconColor: Colors.orange,
        ),
        const SizedBox(height: 12),
        const _TransactionItem(
          id: '#TRX-8822',
          time: '10:30',
          method: 'QRIS',
          amount: 'Rp 120.500',
          icon: Icons.shopping_bag,
          iconColor: Colors.purple,
        ),
        const SizedBox(height: 12),
        const _TransactionItem(
          id: '#TRX-8821',
          time: '09:15',
          method: 'Debit',
          amount: 'Rp 210.000',
          icon: Icons.fastfood,
          iconColor: Colors.blue,
        ),
        // Add padding at bottom for FAB or just scrolling space
        const SizedBox(height: 80), 
      ],
    );
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

class _ChartBar extends StatelessWidget {
  final double height; // 0.0 to 1.0
  final bool isSelected;

  const _ChartBar({required this.height, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: 32,
          height: constraints.maxHeight * height,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
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
