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
