import 'package:flutter/material.dart';
import '../mock/app_state.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();

    return SafeArea(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final posts = state.communityPosts;

          return Column(
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
                            '${state.school ?? "Your School"} — ${state.cohort?.name ?? ""}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showNewPostDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Ask'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Posts list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _PostCard(
                      post: post,
                      onTap: () => _openThread(context, post),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNewPostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final state = AppState();

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
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      bodyController.text.isNotEmpty) {
                    state.addCommunityPost(
                      titleController.text,
                      bodyController.text,
                      state.studentName ?? 'Student',
                    );
                    Navigator.of(ctx).pop();
                    setState(() {});
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

  void _openThread(BuildContext context, CommunityPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ThreadScreen(post: post),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: post.isModeratorPost
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
                    backgroundColor: post.isModeratorPost
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Text(
                      post.author[0],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: post.isModeratorPost
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.author,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: post.isModeratorPost
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                  if (post.isModeratorPost) ...[
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
                    _timeAgo(post.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                post.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (post.replies.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${post.replies.length} ${post.replies.length == 1 ? "reply" : "replies"}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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

class _ThreadScreen extends StatefulWidget {
  final CommunityPost post;

  const _ThreadScreen({required this.post});

  @override
  State<_ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<_ThreadScreen> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();

    return Scaffold(
      appBar: AppBar(title: const Text('Thread')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original post
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: widget.post.isModeratorPost
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primaryContainer,
                        child: Text(
                          widget.post.author[0],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: widget.post.isModeratorPost
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.post.author,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text(_timeAgo(widget.post.createdAt),
                              style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.post.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.post.body, style: theme.textTheme.bodyLarge),
                  const Divider(height: 32),

                  // Replies
                  Text(
                    'Replies (${widget.post.replies.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.post.replies.map((reply) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: reply.isModeratorReply
                                ? theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.4)
                                : theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    reply.author,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: reply.isModeratorReply
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                  if (reply.isModeratorReply) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'MOD',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: theme
                                              .colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  Text(
                                    _timeAgo(reply.createdAt),
                                    style: theme.textTheme.labelSmall,
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
                    color:
                        theme.colorScheme.outline.withValues(alpha: 0.2)),
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
                  onPressed: () {
                    if (_replyController.text.isNotEmpty) {
                      state.addReply(
                        widget.post.id,
                        _replyController.text,
                        state.studentName ?? 'Student',
                        isMod: state.isModerator,
                      );
                      _replyController.clear();
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
