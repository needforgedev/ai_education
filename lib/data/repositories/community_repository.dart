import '../../core/supabase/supabase_client.dart';
import '../../core/constants.dart';
import '../models/community_thread.dart';
import '../models/community_reply.dart';

class CommunityRepository {
  /// Fetch all visible threads for a school, newest first.
  Future<List<CommunityThread>> getThreads(String schoolId) async {
    final result = await supabase
        .from(Tables.communityThreads)
        .select()
        .eq('school_id', schoolId)
        .eq('is_hidden', false)
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false);

    return (result as List<dynamic>)
        .map((e) => CommunityThread.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all threads across all schools (moderator view), newest first.
  /// Joins school name for display.
  Future<List<CommunityThread>> getAllThreads() async {
    final result = await supabase
        .from(Tables.communityThreads)
        .select('*, schools(name)')
        .eq('is_hidden', false)
        .order('created_at', ascending: false);

    return (result as List<dynamic>)
        .map((e) => CommunityThread.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Activity stats for the achievements engine. Returns the counts of
  /// threads + replies posted by this author and the set of distinct days
  /// they were active in the community.
  Future<({int threadCount, int distinctRepliedThreads, Set<String> activeDays})>
      getAuthorActivity(String authorId) async {
    final threads = await supabase
        .from(Tables.communityThreads)
        .select('id, created_at')
        .eq('author_id', authorId);
    final replies = await supabase
        .from(Tables.communityReplies)
        .select('thread_id, created_at')
        .eq('author_id', authorId);

    final days = <String>{};
    for (final t in (threads as List)) {
      final raw = (t as Map<String, dynamic>)['created_at'] as String?;
      if (raw != null) days.add(_dayKey(DateTime.parse(raw).toLocal()));
    }
    final repliedThreadIds = <String>{};
    for (final r in (replies as List)) {
      final m = r as Map<String, dynamic>;
      final raw = m['created_at'] as String?;
      if (raw != null) days.add(_dayKey(DateTime.parse(raw).toLocal()));
      final tid = m['thread_id'] as String?;
      if (tid != null) repliedThreadIds.add(tid);
    }

    return (
      threadCount: threads.length,
      distinctRepliedThreads: repliedThreadIds.length,
      activeDays: days,
    );
  }

  static String _dayKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Fetch all active schools (for moderator filter).
  Future<List<Map<String, String>>> getSchoolsList() async {
    final result = await supabase
        .from(Tables.schools)
        .select('id, name')
        .eq('is_active', true)
        .order('name', ascending: true);

    return (result as List<dynamic>)
        .map((e) => {
              'id': e['id'] as String,
              'name': e['name'] as String,
            })
        .toList();
  }

  /// Fetch all replies for a thread, oldest first.
  Future<List<CommunityReply>> getReplies(String threadId) async {
    final result = await supabase
        .from(Tables.communityReplies)
        .select()
        .eq('thread_id', threadId)
        .eq('is_hidden', false)
        .order('created_at', ascending: true);

    return (result as List<dynamic>)
        .map((e) => CommunityReply.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Create a new thread.
  Future<CommunityThread> createThread({
    required String schoolId,
    required String authorId,
    required String authorName,
    required String title,
    required String body,
    bool isModeratorPost = false,
  }) async {
    final data = {
      'school_id': schoolId,
      'author_id': authorId,
      'author_name': authorName,
      'title': title,
      'body': body,
      'is_moderator_post': isModeratorPost,
    };

    final result = await supabase
        .from(Tables.communityThreads)
        .insert(data)
        .select()
        .single();

    return CommunityThread.fromJson(result);
  }

  /// Add a reply to a thread.
  Future<CommunityReply> addReply({
    required String threadId,
    required String authorId,
    required String authorName,
    required String body,
    bool isModeratorReply = false,
  }) async {
    final data = {
      'thread_id': threadId,
      'author_id': authorId,
      'author_name': authorName,
      'body': body,
      'is_moderator_reply': isModeratorReply,
    };

    final result = await supabase
        .from(Tables.communityReplies)
        .insert(data)
        .select()
        .single();

    return CommunityReply.fromJson(result);
  }
}
