import 'package:flutter/material.dart';
import '../mock/app_state.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (state.studentName ?? 'S')[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.studentName ?? 'Student',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Grade ${state.grade ?? "--"} • ${state.cohort?.name ?? ""}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        state.school ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'View and edit your profile',
            onTap: () => _showComingSoon(context),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Password',
            subtitle: 'Change your password',
            onTap: () => _showComingSoon(context),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () => _showComingSoon(context),
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help',
            subtitle: 'FAQ and support',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'AI Education Platform v1.0.0',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                state.reset();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
