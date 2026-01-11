import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreProfile {
  final String name;
  final String address;

  const StoreProfile({
    required this.name,
    required this.address,
  });

  StoreProfile copyWith({String? name, String? address}) {
    return StoreProfile(
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}

final storeProfileProvider =
    NotifierProvider<StoreProfileNotifier, StoreProfile>(
  StoreProfileNotifier.new,
);

class StoreProfileNotifier extends Notifier<StoreProfile> {
  static const _nameKey = 'store_name';
  static const _addressKey = 'store_address';
  bool _loaded = false;

  @override
  StoreProfile build() {
    if (!_loaded) {
      _loaded = true;
      _load();
    }
    return const StoreProfile(
      name: 'Kopi Senja Utama',
      address: 'Jl. Melati No. 12, Jakarta',
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey);
    final address = prefs.getString(_addressKey);
    if (name == null && address == null) return;
    state = state.copyWith(
      name: (name == null || name.trim().isEmpty) ? state.name : name.trim(),
      address: (address == null || address.trim().isEmpty)
          ? state.address
          : address.trim(),
    );
  }

  Future<void> setName(String value) async {
    final trimmed = value.trim();
    state = state.copyWith(name: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, trimmed);
  }

  Future<void> setAddress(String value) async {
    final trimmed = value.trim();
    state = state.copyWith(address: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressKey, trimmed);
  }

  Future<void> setProfile({required String name, required String address}) async {
    await setName(name);
    await setAddress(address);
  }
}
