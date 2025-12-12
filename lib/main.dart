import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/auth/login_screen.dart';
import 'app/theme_controller.dart';

void main() {
  runApp(const MaisonelApp());
}

class MaisonelApp extends StatelessWidget {
  const MaisonelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Maisonel',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
