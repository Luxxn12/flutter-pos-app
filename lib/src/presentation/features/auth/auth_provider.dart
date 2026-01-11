
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase/supabase_providers.dart';

enum UserRole { admin, cashier }

final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.read(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

final authProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = Supabase.instance.client.auth.currentUser;

  return authState.maybeWhen(
    data: (state) => state.session?.user != null,
    orElse: () => currentUser != null,
  );
});

UserRole _parseRole(User? user) {
  final role = user?.userMetadata?['role'] ?? user?.appMetadata?['role'];
  if (role is String && role.toLowerCase() == 'admin') {
    return UserRole.admin;
  }
  return UserRole.cashier;
}

String _displayName(User? user) {
  final name =
      user?.userMetadata?['name'] ?? user?.userMetadata?['full_name'];
  if (name is String && name.trim().isNotEmpty) {
    return name.trim();
  }
  return user?.email ?? 'Pengguna';
}

final userRoleProvider = Provider<UserRole>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = Supabase.instance.client.auth.currentUser;

  return authState.maybeWhen(
    data: (_) => _parseRole(Supabase.instance.client.auth.currentUser),
    orElse: () => _parseRole(currentUser),
  );
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == UserRole.admin;
});

final userDisplayNameProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = Supabase.instance.client.auth.currentUser;

  return authState.maybeWhen(
    data: (_) => _displayName(Supabase.instance.client.auth.currentUser),
    orElse: () => _displayName(currentUser),
  );
});

class AuthController {
  AuthController(this._client);

  final SupabaseClient _client;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.read(supabaseClientProvider));
});
