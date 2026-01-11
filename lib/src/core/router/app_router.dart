import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/product.dart';
import '../../presentation/app_scaffold.dart';
import '../../presentation/features/auth/auth_provider.dart';
import '../../presentation/features/auth/login_screen.dart';
import '../../presentation/features/dashboard/dashboard_screen.dart';
import '../../presentation/features/categories/categories_screen.dart';
import '../../presentation/features/history/history_screen.dart';
import '../../presentation/features/history/history_detail_screen.dart';
import '../../presentation/features/history/history_models.dart';
import '../../presentation/features/products/product_edit_screen.dart';
import '../../presentation/features/products/products_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';
import '../../presentation/features/users/users_screen.dart';
import '../../presentation/features/splash/splash_screen.dart';
import '../../presentation/features/transactions/checkout_screen.dart';
import '../../presentation/features/transactions/pos_screen.dart';

// authProvider is imported from auth_provider.dart

final goRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authProvider);
  final userRole = ref.watch(userRoleProvider);
  final isAdmin = userRole == UserRole.admin;

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Splash screen handles its own redirection
      if (state.uri.path == '/splash') return null;

      if (!isLoggedIn && state.uri.path != '/login') {
        return '/login';
      }
      if (isLoggedIn && state.uri.path == '/login') {
        return '/dashboard';
      }
      if (isLoggedIn && !isAdmin) {
        const adminOnlyPaths = [
          '/products/add',
          '/products/edit',
          '/categories',
          '/users',
        ];
        final isAdminOnly = adminOnlyPaths.any(
          (path) => state.uri.path.startsWith(path),
        );
        if (isAdminOnly) return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(path: '/pos', builder: (context, state) => const PosScreen()),
          GoRoute(
            path: '/checkout',
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/products/edit',
            builder: (context, state) {
              final product = state.extra as Product?;
              if (product == null) {
                return const Scaffold(
                  body: Center(child: Text('Produk tidak ditemukan')),
                );
              }
              return ProductEditScreen(product: product);
            },
          ),
          GoRoute(
            path: '/products/add',
            builder: (context, state) => const ProductEditScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/history/detail',
            builder: (context, state) {
              final tx = state.extra as HistoryTransaction?;
              if (tx == null) {
                return const Scaffold(
                  body: Center(child: Text('Transaksi tidak ditemukan')),
                );
              }
              return HistoryDetailScreen(transaction: tx);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
        ],
      ),
    ],
  );
});
