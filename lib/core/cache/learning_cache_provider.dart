import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'learning_cache.dart';
import 'user_cache.dart';

final learningCacheProvider = Provider<LearningCache>((ref) {
  return LearningCache();
});

final userCacheProvider = Provider<UserCache>((ref) {
  return UserCache();
});
