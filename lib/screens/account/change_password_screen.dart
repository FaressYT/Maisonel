import 'package:flutter/material.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService.changePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
          _confirmPasswordController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.passwordChangedSuccess,
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.changePassword)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: AppLocalizations.of(context)!.currentPassword,
                controller: _currentPasswordController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enterCurrentPassword;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: AppLocalizations.of(context)!.newPassword,
                controller: _newPasswordController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enterNewPassword;
                  }
                  if (value.length < 6) {
                    return AppLocalizations.of(context)!.passwordLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: AppLocalizations.of(context)!.confirmNewPassword,
                controller: _confirmPasswordController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.confirmNewPasswordHint;
                  }
                  if (value != _newPasswordController.text) {
                    return AppLocalizations.of(context)!.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              CustomButton(
                text: AppLocalizations.of(context)!.updatePassword,
                onPressed: _changePassword,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
