import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../mock/app_state.dart';
import 'cohort_confirmation_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _parentController = TextEditingController();
  final _emailController = TextEditingController();
  int? _selectedGrade;

  // School-first: student picks from onboarded schools
  String? _selectedSchool;

  final List<int> _grades = List.generate(10, (i) => i + 3); // 3 to 12

  @override
  void dispose() {
    _nameController.dispose();
    _parentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_nameController.text.isEmpty ||
        _selectedGrade == null ||
        _selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in name, grade, and school')),
      );
      return;
    }

    final cohort = getCohortForGrade(_selectedGrade!);

    AppState().registerStudent(
      name: _nameController.text,
      studentGrade: _selectedGrade!,
      studentSchool: _selectedSchool!,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CohortConfirmationScreen(
          studentName: _nameController.text,
          grade: _selectedGrade!,
          school: _selectedSchool!,
          cohort: cohort,
        ),
      ),
    );
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
              'Your school has been onboarded. Select it below to join.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // School selection first (school-first model)
            DropdownButtonFormField<String>(
              initialValue: _selectedSchool,
              decoration: const InputDecoration(
                labelText: 'Select Your School',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment_outlined),
              ),
              items: mockSchools
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedSchool = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
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
                  .map((g) => DropdownMenuItem(value: g, child: Text('Grade $g')))
                  .toList(),
              onChanged: (val) => setState(() => _selectedGrade = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _parentController,
              decoration: const InputDecoration(
                labelText: 'Parent / Guardian Contact',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
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
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _onContinue,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
