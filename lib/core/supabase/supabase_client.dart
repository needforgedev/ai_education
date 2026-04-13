import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

/// Initialize Supabase — call once in main() before runApp().
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}

/// Shorthand access to the Supabase client instance.
SupabaseClient get supabase => Supabase.instance.client;
