import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../app/router.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _schoolCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _parentController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _selectedGrade;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  // School state — validated via registration code
  String? _schoolId;
  String? _schoolName;
  bool _schoolValidated = false;

  final List<int> _grades = List.generate(10, (i) => i + 3); // 3 to 12

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _nameController.dispose();
    _parentController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateSchoolCode() async {
    final code = _schoolCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter a school code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result =
          await ref.read(studentRepositoryProvider).validateSchoolCode(code);

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _isLoading = false;
          _error = 'Invalid school code. Please check with your school admin.';
        });
        return;
      }

      setState(() {
        _schoolId = result.schoolId;
        _schoolName = result.schoolName;
        _schoolValidated = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not validate code. Please try again.';
      });
    }
  }

  Future<void> _onRegister() async {
    if (_nameController.text.isEmpty ||
        _selectedGrade == null ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(
          () => _error = 'Please fill in all required fields');
      return;
    }

    if (_passwordController.text.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Find cohort for grade
      final cohort = await ref
          .read(studentRepositoryProvider)
          .getCohortForGrade(_selectedGrade!);

      if (cohort == null) {
        setState(() {
          _isLoading = false;
          _error = 'No cohort found for grade $_selectedGrade';
        });
        return;
      }

      // Sign up + create profile
      await ref.read(authProvider.notifier).signUpStudent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            grade: _selectedGrade!,
            schoolId: _schoolId!,
            cohortId: cohort.id,
            schoolName: _schoolName!,
            cohortName: cohort.name,
            guardianContact: _parentController.text.trim().isNotEmpty
                ? _parentController.text.trim()
                : null,
          );

      if (!mounted) return;

      context.push(AppRoutes.cohortConfirmation, extra: {
        'studentName': _nameController.text.trim(),
        'grade': _selectedGrade!,
        'school': _schoolName!,
        'cohort': cohort,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Registration',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your school code to get started.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Step 1: School code validation
            TextField(
              controller: _schoolCodeController,
              enabled: !_schoolValidated,
              decoration: InputDecoration(
                labelText: 'School Registration Code',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                suffixIcon: _schoolValidated
                    ? Icon(Icons.check_circle,
                        color: theme.colorScheme.primary)
                    : null,
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!_schoolValidated) _validateSchoolCode();
              },
            ),
            if (!_schoolValidated) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _validateSchoolCode,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Validate Code'),
                ),
              ),
            ],

            // Step 2: School confirmed — show name + registration form
            if (_schoolValidated) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.apartment,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _schoolName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _schoolValidated = false;
                          _schoolId = null;
                          _schoolName = null;
                          _schoolCodeController.clear();
                        });
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _selectedGrade,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: _grades
                    .map((g) =>
                        DropdownMenuItem(value: g, child: Text('Grade $g')))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGrade = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outlined),
                  helperText: 'Minimum 8 characters',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _parentController,
                decoration: const InputDecoration(
                  labelText: 'Parent / Guardian Contact (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: theme.colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_schoolValidated) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _onRegister,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Register'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
