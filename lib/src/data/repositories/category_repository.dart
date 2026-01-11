import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/category.dart';
import '../supabase/supabase_providers.dart';

class CategoryRepository {
  CategoryRepository(this._client);

  final SupabaseClient _client;

  Future<List<Category>> fetchCategories() async {
    final data = await _client
        .from('categories')
        .select('id,name')
        .order('name');

    return data
        .map<Category>(
          (row) => Category(
            id: row['id'] as String,
            name: row['name'] as String,
          ),
        )
        .toList();
  }

  Future<Category> createCategory(String name) async {
    final data = await _client
        .from('categories')
        .insert({'name': name})
        .select('id,name')
        .single();

    return Category(id: data['id'] as String, name: data['name'] as String);
  }

  Future<Category> updateCategory(String id, String name) async {
    final data = await _client
        .from('categories')
        .update({'name': name})
        .eq('id', id)
        .select('id,name')
        .single();

    return Category(id: data['id'] as String, name: data['name'] as String);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.read(supabaseClientProvider));
});
