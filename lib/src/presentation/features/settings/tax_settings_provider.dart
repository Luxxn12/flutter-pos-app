import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaxSettings {
  final bool enabled;
  final double rate;

  const TaxSettings({
    required this.enabled,
    required this.rate,
  });

  TaxSettings copyWith({bool? enabled, double? rate}) {
    return TaxSettings(
      enabled: enabled ?? this.enabled,
      rate: rate ?? this.rate,
    );
  }
}

final taxSettingsProvider =
    NotifierProvider<TaxSettingsNotifier, TaxSettings>(
  TaxSettingsNotifier.new,
);

class TaxSettingsNotifier extends Notifier<TaxSettings> {
  static const _enabledKey = 'tax_enabled';
  static const _rateKey = 'tax_rate';
  bool _loaded = false;

  @override
  TaxSettings build() {
    if (!_loaded) {
      _loaded = true;
      _load();
    }
    return const TaxSettings(enabled: true, rate: 10);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey);
    final rate = prefs.getDouble(_rateKey);
    if (enabled == null && rate == null) return;
    state = state.copyWith(
      enabled: enabled ?? state.enabled,
      rate: rate ?? state.rate,
    );
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  Future<void> setRate(double value) async {
    final normalized = value.clamp(0, 100).toDouble();
    state = state.copyWith(rate: normalized);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_rateKey, normalized);
  }
}
