import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/connectivity/connectivity_provider.dart';
import '../core/connectivity/offline_gate.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/community/providers/community_provider.dart';
import '../data/models/community_thread.dart';
import '../data/models/community_reply.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final online = ref.watch(isOnlineProvider);

    if (!online) {
      return const SafeArea(
        child: OfflineGate(
          body: 'Community needs internet to show and post messages. Reconnect to chat with your classmates.',
        ),
      );
    }

    final threadsAsync = ref.watch(communityThreadsProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        auth.isModerator
                            ? 'All Schools'
                            : '${auth.schoolName ?? "Your School"} — ${auth.cohortName ?? ""}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!auth.isModerator)
                  FilledButton.icon(
                    onPressed: () => _showNewPostDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ask'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Posts list
          Expanded(
            child: threadsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load community',
                        style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () =>
                          ref.invalidate(communityThreadsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (threads) {
                if (threads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.forum_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No posts yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )),
                        const SizedBox(height: 4),
                        Text(
                            auth.isModerator
                                ? 'Student posts will appear here'
                                : 'Be the first to ask a doubt!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(communityThreadsProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: threads.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final thread = threads[index];
                      return _PostCard(
                        thread: thread,
                        showSchoolName: auth.isModerator,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _ThreadScreen(
                              thread: thread,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNewPostDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final auth = ref.read(authProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ask a Doubt',
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Your question',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      bodyController.text.isNotEmpty) {
                    await ref
                        .read(communityThreadsProvider.notifier)
                        .createThread(
                          schoolId: auth.studentProfile!.schoolId,
                          title: titleController.text,
                          body: bodyController.text,
                        );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Post Card ----

class _PostCard extends StatelessWidget {
  final CommunityThread thread;
  final bool showSchoolName;
  final VoidCallback onTap;

  const _PostCard({
    required this.thread,
    required this.showSchoolName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: thread.isModeratorPost
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
          : theme.colorScheme.surfaceContainerLow,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // School name badge (moderator view only)
              if (showSchoolName && thread.schoolName != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    thread.schoolName!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: thread.isModeratorPost
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Text(
                      thread.authorName[0],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: thread.isModeratorPost
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    thread.authorName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: thread.isModeratorPost
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                  if (thread.isModeratorPost) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'MOD',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    _timeAgo(thread.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                thread.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                thread.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Thread Screen (replies) ----

class _ThreadScreen extends ConsumerStatefulWidget {
  final CommunityThread thread;

  const _ThreadScreen({required this.thread});

  @override
  ConsumerState<_ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends ConsumerState<_ThreadScreen> {
  final _replyController = TextEditingController();
  late List<CommunityReply> _replies;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _replies = [];
    _loadReplies();
  }

  Future<void> _loadReplies() async {
    try {
      final repo = ref.read(communityRepositoryProvider);
      final replies = await repo.getReplies(widget.thread.id);
      if (mounted) {
        setState(() {
          _replies = replies;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final auth = ref.read(authProvider);
      final repo = ref.read(communityRepositoryProvider);
      final reply = await repo.addReply(
        threadId: widget.thread.id,
        authorId: auth.user!.id,
        authorName: auth.isModerator
            ? 'Moderator'
            : (auth.studentProfile?.fullName ?? 'Student'),
        body: text,
        isModeratorReply: auth.isModerator,
      );

      _replyController.clear();
      setState(() {
        _replies.add(reply);
        _isSending = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.thread.schoolName != null
            ? 'Thread — ${widget.thread.schoolName}'
            : 'Thread'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Original post
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  widget.thread.isModeratorPost
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.primaryContainer,
                              child: Text(
                                widget.thread.authorName[0],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: widget.thread.isModeratorPost
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(widget.thread.authorName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text(
                                    _timeAgo(widget.thread.createdAt),
                                    style: theme.textTheme.labelSmall),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.thread.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.thread.body,
                            style: theme.textTheme.bodyLarge),
                        const Divider(height: 32),

                        // Replies
                        Text(
                          'Replies (${_replies.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_replies.isEmpty)
                          Text('No replies yet. Be the first!',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                              )),
                        ..._replies.map((reply) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: reply.isModeratorReply
                                      ? theme
                                          .colorScheme.primaryContainer
                                          .withValues(alpha: 0.4)
                                      : theme.colorScheme
                                          .surfaceContainerLow,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          reply.authorName,
                                          style: theme
                                              .textTheme.labelMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                reply.isModeratorReply
                                                    ? theme.colorScheme
                                                        .primary
                                                    : null,
                                          ),
                                        ),
                                        if (reply
                                            .isModeratorReply) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 5,
                                                vertical: 1),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      4),
                                            ),
                                            child: Text(
                                              'MOD',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: theme.colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const Spacer(),
                                        Text(
                                          _timeAgo(reply.createdAt),
                                          style: theme
                                              .textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(reply.body),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
          ),

          // Reply input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                    color: theme.colorScheme.outline
                        .withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSending ? null : _sendReply,
                  icon: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'just now';
}
