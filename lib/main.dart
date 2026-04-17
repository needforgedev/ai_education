import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/cache/learning_cache.dart';
import 'core/cache/user_cache.dart';
import 'core/supabase/supabase_client.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LearningCache.init();
  await UserCache.init();
  await initSupabase();

  runApp(
    const ProviderScope(
      child: AiEducationApp(),
    ),
  );
}
