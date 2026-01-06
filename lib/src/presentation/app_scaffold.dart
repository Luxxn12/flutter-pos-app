
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/pos');
        break;
      case 2:
        context.go('/products');
        break;
      case 3:
        context.go('/history');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/pos')) return 1;
    if (location.startsWith('/products')) return 2;
    if (location.startsWith('/history')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800; // Use consistent breakpoint
    final index = _calculateSelectedIndex(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (isMobile) {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12);
              }
              return TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: colorScheme.primary);
              }
              return IconThemeData(color: colorScheme.onSurfaceVariant);
            }),
            indicatorColor: Colors.transparent,
          ),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: _onDestinationSelected,
            height: 72,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined), 
                selectedIcon: Icon(Icons.grid_view_rounded), 
                label: 'Dashboard'
              ),
              NavigationDestination(
                icon: Icon(Icons.swap_horiz_outlined), 
                selectedIcon: Icon(Icons.swap_horiz_rounded), 
                label: 'Transaksi'
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined), 
                selectedIcon: Icon(Icons.inventory_2_rounded), 
                label: 'Produk'
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined), 
                selectedIcon: Icon(Icons.history_rounded), 
                label: 'Riwayat'
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded), 
                selectedIcon: Icon(Icons.person_rounded), 
                label: 'Akun'
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: _onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            groupAlignment: -0.9,
            minWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 24),
              child: Icon(Icons.store_rounded, size: 40, color: Theme.of(context).colorScheme.primary),
            ),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            selectedIconTheme: const IconThemeData(color: Color(0xFF00BFA5)),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.grid_view_outlined), 
                selectedIcon: Icon(Icons.grid_view_rounded), 
                label: Text('Dashboard')
              ),
              NavigationRailDestination(
                icon: Icon(Icons.swap_horiz_outlined), 
                selectedIcon: Icon(Icons.swap_horiz_rounded), 
                label: Text('Transaksi')
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined), 
                selectedIcon: Icon(Icons.inventory_2_rounded), 
                label: Text('Produk')
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined), 
                selectedIcon: Icon(Icons.history_rounded), 
                label: Text('Riwayat')
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline_rounded), 
                selectedIcon: Icon(Icons.person_rounded), 
                label: Text('Akun')
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
