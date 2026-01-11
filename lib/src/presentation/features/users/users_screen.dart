import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import 'users_provider.dart';
import '../../widgets/top_toast.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final cashiersAsync = ref.watch(cashiersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kelola Pengguna')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Akses kelola pengguna hanya untuk admin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        centerTitle: true,
      ),
      body: cashiersAsync.when(
        data: (cashiers) {
          if (cashiers.isEmpty) {
            return const Center(child: Text('Belum ada kasir.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cashiers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cashier = cashiers[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        cashier.name.isNotEmpty
                            ? cashier.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cashier.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cashier.email,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Kasir',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: colorScheme.error),
                      onPressed: () => _confirmDeleteCashier(
                        context,
                        ref,
                        cashier.id,
                        cashier.name,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Gagal memuat kasir: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddCashierDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openAddCashierDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kasir'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != true) return;
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showTopToast(
        context,
        message: 'Nama, email, dan password wajib diisi.',
        type: ToastType.error,
      );
      return;
    }
    if (password.length < 6) {
      showTopToast(
        context,
        message: 'Password minimal 6 karakter.',
        type: ToastType.error,
      );
      return;
    }

    try {
      await ref
          .read(cashiersProvider.notifier)
          .addCashier(name: name, email: email, password: password);
      if (context.mounted) {
        showTopToast(
          context,
          message: 'Kasir berhasil ditambahkan.',
          type: ToastType.success,
        );
      }
    } catch (error) {
      if (context.mounted) {
        showTopToast(
          context,
          message: 'Gagal menambah kasir: $error',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _confirmDeleteCashier(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kasir'),
        content: Text('Hapus akun kasir "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(cashiersProvider.notifier).deleteCashier(id);
      if (context.mounted) {
        showTopToast(
          context,
          message: 'Kasir berhasil dihapus.',
          type: ToastType.success,
        );
      }
    } catch (error) {
      if (context.mounted) {
        showTopToast(
          context,
          message: 'Gagal menghapus kasir: $error',
          type: ToastType.error,
        );
      }
    }
  }
}
