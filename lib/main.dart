import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/auth/login_screen.dart';
import 'app/theme_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/user_cubit.dart';
import 'services/api_service.dart';

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
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => UserCubit()..setUser(ApiService.currentUser),
            ),
          ],
          child: MaterialApp(
            title: 'Maisonel',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const LoginScreen(),
          ),
        );
      },
    );
  }
}
