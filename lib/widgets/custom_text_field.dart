import 'package:flutter/material.dart';
import '../theme.dart';

enum TextFieldType { text, email, password, phone, number }

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextFieldType type;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.type = TextFieldType.text,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
    this.keyboardType,
    this.obscureText,
    this.suffix,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          obscureText:
              widget.obscureText ??
              (widget.type == TextFieldType.password && _obscureText),
          keyboardType: widget.keyboardType ?? _getKeyboardType(),
          validator: widget.validator,
          readOnly: widget.readOnly,
          maxLines: widget.type == TextFieldType.password ? 1 : widget.maxLines,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint ?? widget.label,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color:
                        Theme.of(context).iconTheme.color?.withOpacity(0.7) ??
                        Colors.grey,
                  )
                : null,
            suffix: widget.suffix,
            suffixIcon: widget.suffix == null &&
                    widget.type == TextFieldType.password
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color:
                          Theme.of(context).iconTheme.color?.withOpacity(0.7) ??
                          Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.text:
      case TextFieldType.password:
        return TextInputType.text;
    }
  }
}
