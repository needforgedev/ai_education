import '../../core/cache/learning_cache.dart';
import '../../core/constants.dart';
import '../../core/supabase/supabase_client.dart';
import '../models/course.dart';

/// Course reads: cache-first, Supabase fallback (for online-only first load).
/// Writes: none — courses are authored via seed script, not by users.
class CourseRepository {
  final LearningCache _cache;

  CourseRepository(this._cache);

  /// Returns cached courses if present; otherwise fetches from Supabase and caches.
  /// When offline + cache empty, returns an empty list.
  Future<List<Course>> getCoursesForCohort(String cohortId) async {
    final cached = _cache.getCoursesForCohort(cohortId);
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final remote = await fetchRemoteCoursesForCohort(cohortId);
      await _cache.saveCoursesForCohort(cohortId, remote);
      return remote;
    } catch (_) {
      return const [];
    }
  }

  /// Fetches courses straight from Supabase (bypassing cache). Used by sync.
  Future<List<Course>> fetchRemoteCoursesForCohort(String cohortId) async {
    final result = await supabase
        .from(Tables.courses)
        .select()
        .eq('cohort_id', cohortId)
        .eq('is_published', true)
        .order('order_index', ascending: true);

    return (result as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
