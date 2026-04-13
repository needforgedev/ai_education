import 'package:flutter/material.dart';
import 'theme.dart';
// TODO: import router once GoRouter is set up in Step 5
// For now, keep the existing WelcomeScreen as home
import '../screens/welcome_screen.dart';

class AiEducationApp extends StatelessWidget {
  const AiEducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Education',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const WelcomeScreen(),
    );
  }
}
