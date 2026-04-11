import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const AiEducationApp());
}

ThemeData _buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    brightness: brightness,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

class AiEducationApp extends StatelessWidget {
  const AiEducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Education',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const WelcomeScreen(),
    );
  }
}
