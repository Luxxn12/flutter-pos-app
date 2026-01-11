import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/category.dart';
import 'categories_provider.dart';
import '../auth/auth_provider.dart';
import '../../widgets/top_toast.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kategori Produk'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Akses kategori hanya untuk admin.',
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
        title: const Text('Kategori Produk'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Belum ada kategori.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _openCategoryDialog(
                        context,
                        ref,
                        category: category,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: colorScheme.error),
                      onPressed: () => _confirmDelete(context, ref, category),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Gagal memuat kategori: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final controller = TextEditingController(text: category?.name ?? '');
    final isEditing = category != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Kategori' : 'Tambah Kategori'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nama kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final name = controller.text.trim();
    if (name.isEmpty) return;

    try {
      if (isEditing) {
        await ref
            .read(categoriesProvider.notifier)
            .updateCategory(category!.id, name);
        if (context.mounted) {
          showTopToast(
            context,
            message: 'Kategori berhasil diperbarui.',
            type: ToastType.success,
          );
        }
      } else {
        await ref.read(categoriesProvider.notifier).createCategory(name);
        if (context.mounted) {
          showTopToast(
            context,
            message: 'Kategori berhasil ditambahkan.',
            type: ToastType.success,
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        showTopToast(
          context,
          message: 'Gagal menyimpan kategori: $error',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Hapus kategori "${category.name}"?'),
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
      await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
      if (context.mounted) {
        showTopToast(
          context,
          message: 'Kategori berhasil dihapus.',
          type: ToastType.success,
        );
      }
    } catch (error) {
      if (context.mounted) {
        showTopToast(
          context,
          message: 'Gagal menghapus kategori: $error',
          type: ToastType.error,
        );
      }
    }
  }
}
