import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../auth/providers/auth_provider.dart';

/// Generic single-field editor used by Settings → Profile / Email.
///
/// Pass [kind] to pick name vs email behavior; the screen takes care of
/// validation, hitting Supabase, refreshing local state, and the success/error
/// snackbar copy.
enum EditFieldKind { name, email }

class EditFieldScreen extends ConsumerStatefulWidget {
  final EditFieldKind kind;
  final String initialValue;

  const EditFieldScreen({
    super.key,
    required this.kind,
    required this.initialValue,
  });

  @override
  ConsumerState<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends ConsumerState<EditFieldScreen> {
  late final TextEditingController _controller;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _validate(String value) {
    final trimmed = value.trim();
    switch (widget.kind) {
      case EditFieldKind.name:
        if (trimmed.isEmpty) return 'Name cannot be empty';
        if (trimmed.length < 2) return 'Name is too short';
        return '';
      case EditFieldKind.email:
        if (trimmed.isEmpty) return 'Email cannot be empty';
        final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
        if (!ok) return 'Enter a valid email';
        return '';
    }
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    final err = _validate(value);
    if (err.isNotEmpty) {
      setState(() => _error = err);
      return;
    }
    if (value == widget.initialValue.trim()) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final auth = ref.read(authProvider);
      final userId = auth.user?.id;
      if (userId == null) {
        throw Exception('Not signed in');
      }

      switch (widget.kind) {
        case EditFieldKind.name:
          await ref
              .read(studentRepositoryProvider)
              .updateFullName(userId: userId, fullName: value);
          await ref.read(authProvider.notifier).refreshProfile();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name updated')),
          );
          Navigator.of(context).pop();
          break;
        case EditFieldKind.email:
          await ref.read(authRepositoryProvider).updateEmail(value);
          if (!mounted) return;
          // Email isn't applied until the student clicks the confirmation
          // link sent to BOTH addresses by Supabase.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              content: Text(
                "Confirmation links sent to both your old and new email — click both to finish the change.",
              ),
            ),
          );
          Navigator.of(context).pop();
          break;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmail = widget.kind == EditFieldKind.email;
    final title = isEmail ? 'Change email' : 'Edit name';
    final fieldLabel = isEmail ? 'EMAIL' : 'FULL NAME';
    final hint = isEmail ? 'jordan@school.edu' : 'Jordan Lee';
    final subtitle = isEmail
        ? 'We\'ll send a confirmation link to both your old and new email. The change happens once you click the link.'
        : 'This is what classmates and moderators see when you post in the community.';

    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
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
                        'Settings',
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
              Text(title, style: theme.textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppPalette.textSoft, height: 1.5),
              ),
              const SizedBox(height: 24),
              Text(fieldLabel, style: AppText.eyebrow(context)),
              const SizedBox(height: 6),
              TextField(
                controller: _controller,
                autofocus: true,
                enabled: !_busy,
                keyboardType: isEmail
                    ? TextInputType.emailAddress
                    : TextInputType.name,
                textCapitalization: isEmail
                    ? TextCapitalization.none
                    : TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  hintText: hint,
                  errorText: _error,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
