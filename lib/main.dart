import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MaisonelApp());
}

class MaisonelApp extends StatelessWidget {
  const MaisonelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maisonel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
