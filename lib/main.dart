
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  // TODO: Register Adapters
  // Hive.registerAdapter(ProductAdapter());
  
  // Open boxes
  await Hive.openBox('settings');
  await Hive.openBox('cart');

  await Supabase.initialize(
    url: 'https://idoibtvlehlvcuinhaub.supabase.co',
    anonKey: 'sb_publishable_yqr4RuKbS9PoHBmArk_KgQ_plTiaQzi',
  );

  await initializeDateFormatting('id_ID', null);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
