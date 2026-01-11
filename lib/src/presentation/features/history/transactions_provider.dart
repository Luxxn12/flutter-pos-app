import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/transaction_repository.dart';
import 'history_models.dart';

class TransactionsNotifier extends AsyncNotifier<List<HistoryTransaction>> {
  @override
  Future<List<HistoryTransaction>> build() async {
    final repo = ref.read(transactionRepositoryProvider);
    return repo.fetchTransactions();
  }

  Future<void> refresh() async {
    final repo = ref.read(transactionRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(repo.fetchTransactions);
  }

  Future<HistoryTransaction> createTransaction(
    Future<HistoryTransaction> Function() creator,
  ) async {
    final created = await creator();
    state = state.whenData((items) => [created, ...items]);
    return created;
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<HistoryTransaction>>(
  TransactionsNotifier.new,
);
