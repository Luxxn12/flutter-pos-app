import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/category_repository.dart';
import '../../../domain/entities/category.dart';

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final repo = ref.read(categoryRepositoryProvider);
    return repo.fetchCategories();
  }

  Future<void> refresh() async {
    final repo = ref.read(categoryRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(repo.fetchCategories);
  }

  Future<Category> createCategory(String name) async {
    final repo = ref.read(categoryRepositoryProvider);
    final created = await repo.createCategory(name);
    state = state.whenData((items) => [...items, created]);
    return created;
  }

  Future<Category> updateCategory(String id, String name) async {
    final repo = ref.read(categoryRepositoryProvider);
    final updated = await repo.updateCategory(id, name);
    state = state.whenData(
      (items) => items.map((c) => c.id == id ? updated : c).toList(),
    );
    return updated;
  }

  Future<void> deleteCategory(String id) async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.deleteCategory(id);
    state = state.whenData((items) => items.where((c) => c.id != id).toList());
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);
