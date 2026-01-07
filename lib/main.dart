import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';
import 'theme.dart';
import 'screens/auth/login_screen.dart';
import 'app/theme_controller.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/apartment/apartment_cubit.dart';
import 'cubits/order/order_cubit.dart';
import 'cubits/user/user_cubit.dart';
import 'cubits/language/language_cubit.dart';

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
        BlocProvider(create: (_) => LanguageCubit()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.instance.themeNotifier,
        builder: (context, themeMode, _) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                title: 'Maisonel',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: languageState.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                home: const LoginScreen(),

                // TODO: fix apartment upload photos when editing apartment
                // TODO: whenever someone opens an apartment, add a view
                // TODO: add ammenities in the listing addition / editing
                // TODO: when someone orders a booking, it should have his name and number in the booking request.
                // TODO: edit profile option back + froot
              );
            },
          );
        },
      ),
    );
  }
}
