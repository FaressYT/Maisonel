import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../cubits/auth/auth_cubit.dart';
import 'signup_screen.dart';
import '../main_screen.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _phoneController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.replaceAll('Exception: ', '')),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Container(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and Title
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.large,
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Maisonel',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppLocalizations.of(context)!.findDreamHome,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textWhite.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // Login Form Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.large,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.welcomeBack,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Email Field
                              CustomTextField(
                                label: AppLocalizations.of(context)!.phone,
                                hint: AppLocalizations.of(
                                  context,
                                )!.enterPhoneNumber,
                                type: TextFieldType.phone,
                                controller: _phoneController,
                                prefixIcon: Icons.phone_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterPhoneNumber;
                                  }
                                  if (!value.startsWith('09')) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.validPhoneStart09;
                                  }
                                  if (value.length < 9) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.validPhone;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Password Field
                              CustomTextField(
                                label: AppLocalizations.of(context)!.password,
                                hint: AppLocalizations.of(
                                  context,
                                )!.enterPassword,
                                type: TextFieldType.password,
                                controller: _passwordController,
                                prefixIcon: Icons.lock_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterPassword;
                                  }
                                  if (value.length < 6) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.passwordLength;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Remember Me and Forgot Password
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              // Login Button
                              CustomButton(
                                text: AppLocalizations.of(context)!.login,
                                onPressed: _handleLogin,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Sign Up Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.dontHaveAccount,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.signUp,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
