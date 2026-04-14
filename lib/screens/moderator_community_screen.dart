import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/community/providers/community_provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../data/models/community_thread.dart';
import '../data/models/community_reply.dart';

/// Moderator community browser: Schools → Threads → Replies
class ModeratorCommunityScreen extends ConsumerWidget {
  const ModeratorCommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final schoolsAsync = ref.watch(schoolsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: schoolsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load schools',
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(schoolsListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (schools) {
          if (schools.isEmpty) {
            return Center(
              child: Text('No schools found',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: schools.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final school = schools[index];
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      school['name']![0],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(school['name']!,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _SchoolThreadsScreen(
                          schoolId: school['id']!,
                          schoolName: school['name']!,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Threads for a specific school (moderator view)
class _SchoolThreadsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String schoolName;

  const _SchoolThreadsScreen({
    required this.schoolId,
    required this.schoolName,
  });

  @override
  ConsumerState<_SchoolThreadsScreen> createState() =>
      _SchoolThreadsScreenState();
}

class _SchoolThreadsScreenState
    extends ConsumerState<_SchoolThreadsScreen> {
  List<CommunityThread>? _threads;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(communityRepositoryProvider);
      final threads = await repo.getThreads(widget.schoolId);
      if (mounted) {
        setState(() {
          _threads = threads;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load threads';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.schoolName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _loadThreads,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _threads!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forum_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text('No threads in this school yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                              )),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadThreads,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _threads!.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final thread = _threads![index];
                          return _ModPostCard(
                            thread: thread,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => _ModThreadScreen(
                                    thread: thread,
                                    schoolName: widget.schoolName,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ModPostCard extends StatelessWidget {
  final CommunityThread thread;
  final VoidCallback onTap;

  const _ModPostCard({required this.thread, required this.onTap});

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

/// Thread detail for moderator — can read + reply
class _ModThreadScreen extends ConsumerStatefulWidget {
  final CommunityThread thread;
  final String schoolName;

  const _ModThreadScreen({
    required this.thread,
    required this.schoolName,
  });

  @override
  ConsumerState<_ModThreadScreen> createState() =>
      _ModThreadScreenState();
}

class _ModThreadScreenState extends ConsumerState<_ModThreadScreen> {
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
        authorName: 'Moderator',
        body: text,
        isModeratorReply: true,
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
      appBar: AppBar(title: Text('Thread — ${widget.schoolName}')),
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
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  widget.thread.isModeratorPost
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme
                                          .primaryContainer,
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
                        Text(
                          'Replies (${_replies.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_replies.isEmpty)
                          Text('No replies yet.',
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
                      hintText: 'Reply as moderator...',
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
