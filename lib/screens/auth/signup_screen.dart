import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../main_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthdateController = TextEditingController();
  File? _profileImage;
  File? _idImage;
  bool _acceptTerms = false;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedBirthdate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
      setState(() {
        if (isProfile) {
          _profileImage = File(image.path);
        } else {
          _idImage = File(image.path);
        }
      });
    }
  }

  void _handleSignup() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms and conditions'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a profile picture')),
        );
        return;
      }
      if (_idImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your ID photo')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to main screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                          'Create Account',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Join Maisonel today',
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
                            borderRadius: BorderRadius.circular(AppRadius.lg),
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
                                          image: _profileImage != null
                                              ? DecorationImage(
                                                  image: FileImage(
                                                    _profileImage!,
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
                                            padding: const EdgeInsets.all(4),
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

                                // Full Name Field
                                CustomTextField(
                                  label: 'Full Name',
                                  hint: 'Enter your full name',
                                  controller: _nameController,
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // Birthdate Field
                                CustomTextField(
                                  label: 'Birthdate',
                                  hint: 'Select your birthdate',
                                  controller: _birthdateController,
                                  prefixIcon: Icons.calendar_today,
                                  readOnly: true,
                                  onTap: () => _selectDate(context),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select your birthdate';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // Email Field
                                CustomTextField(
                                  label: 'Phone Number',
                                  hint: 'Enter your Phone Number',
                                  type: TextFieldType.email,
                                  controller: _emailController,
                                  prefixIcon: Icons.phone_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // Password Field
                                CustomTextField(
                                  label: 'Password',
                                  hint: 'Create a password',
                                  type: TextFieldType.password,
                                  controller: _passwordController,
                                  prefixIcon: Icons.lock_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // Confirm Password Field
                                CustomTextField(
                                  label: 'Confirm Password',
                                  hint: 'Re-enter your password',
                                  type: TextFieldType.password,
                                  controller: _confirmPasswordController,
                                  prefixIcon: Icons.lock_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // ID Photo Upload
                                Text(
                                  'ID Photo',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
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
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.md,
                                            ),
                                            child: Image.file(
                                              _idImage!,
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
                                                'Tap to upload ID photo',
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            'I agree to the ',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              // TODO: Show terms and conditions
                                            },
                                            child: Text(
                                              'Terms and Conditions',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
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
                                  text: 'Sign Up',
                                  onPressed: _handleSignup,
                                  isLoading: _isLoading,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // Login Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Login',
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
      ),
    );
  }
}
