import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../domain/entities/user_account.dart';

class CashierListNotifier extends AsyncNotifier<List<UserAccount>> {
  @override
  Future<List<UserAccount>> build() async {
    final repo = ref.read(userRepositoryProvider);
    return repo.fetchCashiers();
  }

  Future<void> refresh() async {
    final repo = ref.read(userRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(repo.fetchCashiers);
  }

  Future<UserAccount> addCashier({
    required String name,
    required String email,
    required String password,
  }) async {
    final repo = ref.read(userRepositoryProvider);
    final created = await repo.createCashier(
      name: name,
      email: email,
      password: password,
    );
    state = state.whenData((items) => [created, ...items]);
    return created;
  }

  Future<void> deleteCashier(String id) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.deleteCashier(id);
    state = state.whenData((items) => items.where((c) => c.id != id).toList());
  }
}

final cashiersProvider =
    AsyncNotifierProvider<CashierListNotifier, List<UserAccount>>(
  CashierListNotifier.new,
);
