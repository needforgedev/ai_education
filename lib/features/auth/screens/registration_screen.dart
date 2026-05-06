import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../providers/auth_provider.dart';

/// Step-based registration matching the Teen "builder energy" pattern:
///   step 0 — school code (or "I'm learning on my own")
///   step 1 — full name
///   step 2 — grade (3-col grid)
///   step 3 — email + password (+ optional guardian contact)
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  int _step = 0;
  static const int _stepCount = 4;

  final _schoolCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _guardianController = TextEditingController();
  int? _selectedGrade;
  bool _obscurePassword = true;
  bool _isBusy = false;
  String? _error;

  String? _schoolId;
  String? _schoolName;

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _guardianController.dispose();
    super.dispose();
  }

  Future<void> _validateSchoolCode({required String code}) async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final result =
          await ref.read(studentRepositoryProvider).validateSchoolCode(code);
      if (!mounted) return;
      if (result == null) {
        setState(() {
          _isBusy = false;
          _error = 'Invalid school code. Check with your school admin.';
        });
        return;
      }
      setState(() {
        _schoolId = result.schoolId;
        _schoolName = result.schoolName;
        _isBusy = false;
        _step = 1;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _error = 'Could not validate code. Try again.';
      });
    }
  }

  Future<void> _continueAsIndependent() async {
    await _validateSchoolCode(code: 'INDEPENDENT');
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final cohort = await ref
          .read(studentRepositoryProvider)
          .getCohortForGrade(_selectedGrade!);
      if (cohort == null) {
        setState(() {
          _isBusy = false;
          _error = 'No cohort found for grade $_selectedGrade';
        });
        return;
      }

      await ref.read(authProvider.notifier).signUpStudent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            grade: _selectedGrade!,
            schoolId: _schoolId!,
            cohortId: cohort.id,
            schoolName: _schoolName!,
            cohortName: cohort.name,
            guardianContact: _guardianController.text.trim().isNotEmpty
                ? _guardianController.text.trim()
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
        _isBusy = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ─── Step actions ───
  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _schoolCodeController.text.trim().isNotEmpty;
      case 1:
        return _nameController.text.trim().isNotEmpty;
      case 2:
        return _selectedGrade != null;
      case 3:
        return _emailController.text.trim().isNotEmpty &&
            _passwordController.text.length >= 8;
      default:
        return false;
    }
  }

  void _onContinue() {
    setState(() => _error = null);
    switch (_step) {
      case 0:
        _validateSchoolCode(code: _schoolCodeController.text.trim().toUpperCase());
        break;
      case 1:
        setState(() => _step = 2);
        break;
      case 2:
        // Grade selection auto-advances; this case won't normally hit
        setState(() => _step = 3);
        break;
      case 3:
        _submitRegistration();
        break;
    }
  }

  void _onBack() {
    setState(() => _error = null);
    if (_step == 0) {
      context.pop();
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackRow(onBack: _onBack),
              const SizedBox(height: 12),
              _ProgressIndicator(step: _step, total: _stepCount),
              const SizedBox(height: 18),
              Text(
                'STEP ${_step + 1} OF $_stepCount',
                style: AppText.eyebrow(context),
              ),
              const SizedBox(height: 6),
              Text(_titleForStep(_step), style: theme.textTheme.displaySmall),
              if (_subtitleForStep(_step) != null) ...[
                const SizedBox(height: 8),
                Text(
                  _subtitleForStep(_step)!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppPalette.textSoft),
                ),
              ],
              const SizedBox(height: 28),
              Expanded(child: _buildStepContent()),
              if (_error != null) ...[
                _ErrorBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              if (_step != 2)
                FilledButton(
                  onPressed:
                      (!_canAdvance || _isBusy) ? null : _onContinue,
                  child: _isBusy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_step == _stepCount - 1 ? 'Create account' : 'Continue'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleForStep(int step) {
    switch (step) {
      case 0:
        return 'School code';
      case 1:
        return "What's your name?";
      case 2:
        return 'Grade level';
      case 3:
      default:
        return 'Almost there';
    }
  }

  String? _subtitleForStep(int step) {
    switch (step) {
      case 0:
        return 'Enter the code your school gave you, or learn on your own.';
      case 3:
        return 'You can use this email to sign in later.';
      default:
        return null;
    }
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildSchoolStep();
      case 1:
        return _SingleField(
          controller: _nameController,
          hint: 'Jordan Lee',
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          autofocus: true,
        );
      case 2:
        return _buildGradeGrid();
      case 3:
      default:
        return _buildAccountStep();
    }
  }

  Widget _buildSchoolStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SingleField(
          controller: _schoolCodeController,
          hint: 'SUNRISE-2026',
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          autofocus: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider(color: AppPalette.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR',
                style: AppText.eyebrow(context),
              ),
            ),
            const Expanded(child: Divider(color: AppPalette.border)),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _isBusy ? null : _continueAsIndependent,
          icon: const Icon(Icons.person_outline, size: 18),
          label: const Text("I'm learning on my own"),
        ),
      ],
    );
  }

  Widget _buildGradeGrid() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(10, (i) {
        final grade = i + 3; // 3..12
        final selected = _selectedGrade == grade;
        return InkWell(
          borderRadius: BorderRadius.circular(AppRadii.input),
          onTap: () {
            setState(() {
              _selectedGrade = grade;
            });
            // Auto-advance after a tiny delay so the user sees the selection
            Future<void>.delayed(const Duration(milliseconds: 180), () {
              if (!mounted) return;
              setState(() => _step = 3);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppPalette.primary : AppPalette.surface,
              borderRadius: BorderRadius.circular(AppRadii.input),
              border: Border.all(
                color: selected ? AppPalette.primary : AppPalette.border,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$grade',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: selected ? Colors.white : AppPalette.text,
                  ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAccountStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(text: 'EMAIL'),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'jordan@school.edu'),
          ),
          const SizedBox(height: 16),
          _FieldLabel(text: 'PASSWORD'),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppPalette.textSoft,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              helperText: 'At least 8 characters',
            ),
          ),
          const SizedBox(height: 16),
          _FieldLabel(text: 'GUARDIAN CONTACT (OPTIONAL)'),
          const SizedBox(height: 6),
          TextField(
            controller: _guardianController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Phone or email'),
          ),
        ],
      ),
    );
  }
}

class _BackRow extends StatelessWidget {
  final VoidCallback onBack;
  const _BackRow({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onBack,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back, size: 20, color: AppPalette.textSoft),
            const SizedBox(width: 6),
            Text(
              'Back',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.textSoft,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int step;
  final int total;
  const _ProgressIndicator({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final filled = i <= step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: filled ? AppPalette.primary : AppPalette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SingleField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;
  final bool autofocus;

  const _SingleField({
    required this.controller,
    required this.hint,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppText.eyebrow(context));
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
