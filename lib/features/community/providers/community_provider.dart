import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../data/models/community_thread.dart';
import '../../../data/models/community_reply.dart';
import '../../auth/providers/auth_provider.dart';

final communityRepositoryProvider =
    Provider((ref) => CommunityRepository());

/// Fetches threads — school-scoped for students, all threads for moderators.
final communityThreadsProvider =
    AsyncNotifierProvider<CommunityThreadsNotifier, List<CommunityThread>>(
        CommunityThreadsNotifier.new);

class CommunityThreadsNotifier
    extends AsyncNotifier<List<CommunityThread>> {
  supa.RealtimeChannel? _threadsChannel;

  @override
  Future<List<CommunityThread>> build() async {
    final auth = ref.read(authProvider);
    final repo = ref.read(communityRepositoryProvider);

    List<CommunityThread> threads;

    if (auth.isModerator) {
      // Moderators see all threads across all schools, with school name
      threads = await repo.getAllThreads();
    } else {
      // Students see only their school's threads
      final schoolId = auth.studentProfile?.schoolId;
      if (schoolId == null) return [];
      threads = await repo.getThreads(schoolId);

      // Realtime subscription for student's school
      _threadsChannel?.unsubscribe();
      _threadsChannel = supabase
          .channel('community_threads_$schoolId')
          .onPostgresChanges(
            event: supa.PostgresChangeEvent.insert,
            schema: 'public',
            table: Tables.communityThreads,
            filter: supa.PostgresChangeFilter(
              type: supa.PostgresChangeFilterType.eq,
              column: 'school_id',
              value: schoolId,
            ),
            callback: (payload) {
              _onNewThread(payload.newRecord);
            },
          )
          .subscribe();
    }

    ref.onDispose(() {
      _threadsChannel?.unsubscribe();
    });

    return threads;
  }

  void _onNewThread(Map<String, dynamic> record) {
    final thread = CommunityThread.fromJson(record);
    final current = state.valueOrNull ?? [];
    if (!current.any((t) => t.id == thread.id)) {
      state = AsyncData([thread, ...current]);
    }
  }

  /// Create a new thread and add it to the list.
  Future<void> createThread({
    required String schoolId,
    required String title,
    required String body,
  }) async {
    final auth = ref.read(authProvider);
    final repo = ref.read(communityRepositoryProvider);

    final thread = await repo.createThread(
      schoolId: schoolId,
      authorId: auth.user!.id,
      authorName: auth.isModerator
          ? 'Moderator'
          : (auth.studentProfile?.fullName ?? 'Student'),
      title: title,
      body: body,
      isModeratorPost: auth.isModerator,
    );

    final current = state.valueOrNull ?? [];
    state = AsyncData([thread, ...current]);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Fetches replies for a specific thread.
final threadRepliesProvider =
    FutureProvider.family<List<CommunityReply>, String>(
        (ref, threadId) async {
  final repo = ref.read(communityRepositoryProvider);
  return repo.getReplies(threadId);
});

/// Fetches list of schools for moderator filter/selection.
final schoolsListProvider =
    FutureProvider<List<Map<String, String>>>((ref) async {
  final repo = ref.read(communityRepositoryProvider);
  return repo.getSchoolsList();
});
