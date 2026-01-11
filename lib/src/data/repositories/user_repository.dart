import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_account.dart';
import '../supabase/supabase_providers.dart';

class UserRepository {
  UserRepository(this._client);

  final SupabaseClient _client;

  Future<List<UserAccount>> fetchCashiers() async {
    final data = await _client
        .from('user_profiles')
        .select('id,name,email,role,created_at')
        .eq('role', 'cashier')
        .order('created_at', ascending: false);

    return data
        .map<UserAccount>(
          (row) => UserAccount.fromMap(row as Map<String, dynamic>),
        )
        .toList();
  }

  Future<UserAccount> createCashier({
    required String name,
    required String email,
    required String password,
  }) async {
    final refreshed = await _client.auth.refreshSession();
    final token =
        refreshed.session?.accessToken ?? _client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan.');
    }
    final response = await _client.functions.invoke(
      'create-cashier',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response.status != 200 || response.data == null) {
      throw Exception(response.data?['message'] ?? 'Gagal membuat kasir.');
    }

    final profile = response.data['profile'] as Map<String, dynamic>;
    return UserAccount.fromMap(profile);
  }

  Future<void> deleteCashier(String id) async {
    final refreshed = await _client.auth.refreshSession();
    final token =
        refreshed.session?.accessToken ?? _client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan.');
    }
    final response = await _client.functions.invoke(
      'delete-cashier',
      headers: {'Authorization': 'Bearer $token'},
      body: {'id': id},
    );
    if (response.status != 200) {
      throw Exception(response.data?['message'] ?? 'Gagal menghapus kasir.');
    }
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(supabaseClientProvider));
});
