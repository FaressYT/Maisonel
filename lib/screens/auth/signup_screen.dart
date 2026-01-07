import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../cubits/auth/auth_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:maisonel_v02/l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthdateController = TextEditingController();
  XFile? _profileImage;
  XFile? _idImage;
  Uint8List? _profileImageBytes;
  Uint8List? _idImageBytes;
  bool _acceptTerms = false;

  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedBirthdate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (isProfile) {
          _profileImage = image;
          _profileImageBytes = bytes;
        } else {
          _idImage = image;
          _idImageBytes = bytes;
        }
      });
    }
  }

  void _handleSignup() {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.acceptTerms),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectProfilePicture),
          ),
        );
        return;
      }
      if (_idImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.uploadIdPhoto)),
        );
        return;
      }

      context.read<AuthCubit>().register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        birthDate: _birthdateController.text,
        photo: _profileImage,
        idDocument: _idImage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Registration successful, show success message and return to login
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.accountCreated),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(); // Return to login screen
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
              child: Column(
                children: [
                  // Back Button
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textWhite,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Form
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.large,
                              ),
                              child: const Icon(
                                Icons.home_rounded,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              AppLocalizations.of(context)!.createAccount,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              AppLocalizations.of(context)!.joinMaisonel,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.textWhite.withOpacity(0.9),
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            // Signup Form Card
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                boxShadow: AppShadows.large,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Profile Picture
                                    Center(
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[200],
                                              image: _profileImageBytes != null
                                                  ? DecorationImage(
                                                      image: MemoryImage(
                                                        _profileImageBytes!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: _profileImage == null
                                                ? const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  )
                                                : null,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () => _pickImage(true),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),

                                    // Name Fields
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextField(
                                            label: AppLocalizations.of(
                                              context,
                                            )!.firstName,
                                            hint: AppLocalizations.of(
                                              context,
                                            )!.firstName,
                                            controller: _firstNameController,
                                            prefixIcon: Icons.person_outline,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return AppLocalizations.of(
                                                  context,
                                                )!.required;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: CustomTextField(
                                            label: AppLocalizations.of(
                                              context,
                                            )!.lastName,
                                            hint: AppLocalizations.of(
                                              context,
                                            )!.lastName,
                                            controller: _lastNameController,
                                            prefixIcon: Icons.person_outline,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return AppLocalizations.of(
                                                  context,
                                                )!.required;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    // Birthdate Field
                                    CustomTextField(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.birthdate,
                                      hint: AppLocalizations.of(
                                        context,
                                      )!.selectBirthdate,
                                      controller: _birthdateController,
                                      prefixIcon: Icons.calendar_today,
                                      readOnly: true,
                                      onTap: () => _selectDate(context),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(
                                            context,
                                          )!.pleaseSelectBirthdate;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    // Email Field
                                    CustomTextField(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.phone,
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
                                      label: AppLocalizations.of(
                                        context,
                                      )!.password,
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
                                    // Confirm Password Field
                                    CustomTextField(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.confirmPassword,
                                      hint: AppLocalizations.of(
                                        context,
                                      )!.reEnterPassword,
                                      type: TextFieldType.password,
                                      controller: _confirmPasswordController,
                                      prefixIcon: Icons.lock_outline,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(
                                            context,
                                          )!.pleaseConfirmPassword;
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
                                    // ID Photo Upload
                                    Text(
                                      AppLocalizations.of(context)!.idPhoto,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    GestureDetector(
                                      onTap: () => _pickImage(false),
                                      child: Container(
                                        height: 150,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.md,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: _idImage != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.md,
                                                    ),
                                                child: Image.memory(
                                                  _idImageBytes!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.add_a_photo_outlined,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(
                                                    height: AppSpacing.xs,
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.tapToUploadId,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    // Terms and Conditions
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _acceptTerms,
                                            onChanged: (value) {
                                              setState(() {
                                                _acceptTerms = value ?? false;
                                              });
                                            },
                                            activeColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Wrap(
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.agreeTo,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  // TODO: Show terms and conditions
                                                },
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.termsOfService,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    // Sign Up Button
                                    CustomButton(
                                      text: AppLocalizations.of(
                                        context,
                                      )!.signUp,
                                      onPressed: _handleSignup,
                                      isLoading: isLoading,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    // Login Link
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.alreadyHaveAccount,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)!.login,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
