import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';
import '../app/theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/settings/screens/edit_field_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _reminders = true;
  bool _sound = false;

  void _comingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final profile = auth.studentProfile;
    final email = auth.user?.email ?? '—';

    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(AppRadii.button),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chevron_left,
                          size: 22, color: AppPalette.textSoft),
                      const SizedBox(width: 4),
                      Text(
                        'Profile',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppPalette.textSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Settings', style: theme.textTheme.displaySmall),
              const SizedBox(height: 24),
              _Section(
                title: 'ACCOUNT',
                children: [
                  _SettingsTile(
                    title: 'Profile',
                    subtitle: profile?.fullName ?? 'Student',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditFieldScreen(
                            kind: EditFieldKind.name,
                            initialValue: profile?.fullName ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  const _Divider(),
                  _SettingsTile(
                    title: 'Email',
                    subtitle: email,
                    onTap: null,
                  ),
                  const _Divider(),
                  _SettingsTile(
                    title: 'Password',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Section(
                title: 'LEARNING',
                children: [
                  _SettingsTile(
                    title: 'Daily goal',
                    subtitle: '20 min',
                    onTap: _comingSoon,
                  ),
                  const _Divider(),
                  _ToggleTile(
                    title: 'Reminders',
                    value: _reminders,
                    onChanged: (v) => setState(() => _reminders = v),
                  ),
                  const _Divider(),
                  _ToggleTile(
                    title: 'Sound',
                    value: _sound,
                    onChanged: (v) => setState(() => _sound = v),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Section(
                title: 'PRIVACY',
                children: [
                  _SettingsTile(
                    title: 'Profile visibility',
                    subtitle: 'Cohort only',
                    onTap: _comingSoon,
                  ),
                  const _Divider(),
                  _SettingsTile(
                    title: 'Block list',
                    onTap: _comingSoon,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Card(
                children: [
                  _SettingsTile(
                    title: 'Help',
                    onTap: _comingSoon,
                  ),
                  const _Divider(),
                  _SignOutTile(
                    onTap: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (!context.mounted) return;
                      context.go(AppRoutes.welcome);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppText.eyebrow(context)),
        ),
        _Card(children: children),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppPalette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppPalette.border);
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// When null, the row is rendered as read-only — no ink ripple, no chevron.
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppPalette.textSoft,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right,
                size: 20, color: AppPalette.textSoft),
        ],
      ),
    );

    if (onTap == null) return body;
    return InkWell(onTap: onTap, child: body);
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppPalette.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
            trackOutlineColor:
                const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _SignOutTile extends StatelessWidget {
  final VoidCallback onTap;
  const _SignOutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Text(
          'Sign out',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
