import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme.dart';
import 'screens/auth/login_screen.dart';
import 'app/theme_controller.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/apartment/apartment_cubit.dart';
import 'cubits/order/order_cubit.dart';
import 'cubits/user/user_cubit.dart';

void main() {
  runApp(const MaisonelApp());
}

class MaisonelApp extends StatelessWidget {
  const MaisonelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()..checkAuthStatus()),
        BlocProvider(create: (_) => ApartmentCubit()),
        BlocProvider(create: (_) => OrderCubit()),
        BlocProvider(create: (_) => UserCubit()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.instance.themeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'Maisonel',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const LoginScreen(),

            // TODO: fix apartment upload photos when editing apartment
            // TODO: whenever someone opens an apartment, add a view
            // TODO: add ammenities in the listing addition / editing
            // TODO: when someone orders a booking, it should have his name and number in the booking request.
          );
        },
      ),
    );
  }
}
