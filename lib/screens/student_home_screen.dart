import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/cache/learning_cache_provider.dart';
import '../core/sync/learning_sync_provider.dart';
import '../features/auth/providers/auth_provider.dart';
import 'student_dashboard_screen.dart';
import 'course_list_screen.dart';
import 'community_screen.dart';
import 'leaderboard_screen.dart';
import '../features/student/screens/profile_screen.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  int _currentIndex = 0;
  bool _syncTriggered = false;

  late final List<Widget> _screens = [
    StudentDashboardScreen(
      onNavigateToCourses: () => setState(() => _currentIndex = 1),
    ),
    const CourseListScreen(),
    const CommunityScreen(),
    const LeaderboardScreen(),
    const ProfileScreen(),
  ];

  void _maybeTriggerSync() {
    if (_syncTriggered) return;
    final auth = ref.read(authProvider);
    final profile = auth.studentProfile;
    if (profile == null) return;

    final cache = ref.read(learningCacheProvider);
    if (cache.hasCoursesForCohort(profile.cohortId)) {
      _syncTriggered = true;
      return;
    }

    _syncTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(learningSyncProvider.notifier).syncCohort(profile.cohortId);
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeTriggerSync();
    final syncState = ref.watch(learningSyncProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          _screens[_currentIndex],
          if (syncState.inProgress) const _SyncOverlay(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Discuss',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Ranks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _SyncOverlay extends StatelessWidget {
  const _SyncOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      alignment: Alignment.center,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Downloading your courses…',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'So you can learn even without internet.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
